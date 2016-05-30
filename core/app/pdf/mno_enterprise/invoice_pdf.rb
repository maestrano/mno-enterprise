module MnoEnterprise
  class InvoicePdf
    attr_reader :invoice, :pdf, :data

    # InvoicePdf requires to be initialized
    # with an Invoice object
    def initialize(invoice)
      raise ArgumentError, "Received #{invoice.class} object (expected instance of Invoice)" unless invoice.is_a?(MnoEnterprise::Invoice)
      @invoice = invoice
      @pdf = nil
      @data = {}

      #===============================
      # Initialize formatting
      #===============================
      @format = {}
      @format[:header_size] = 120
      @format[:footer_size] = 100
      @format[:top_margin] = 36
      @format[:bottom_margin] = 36

      #===============================
      # Data hash
      #===============================
      @data = {}

      # Invoice details
      @data[:invoice_reference] = @invoice.slug

      # Customer details
      invoicable = @invoice.organization
      [:name, :email, :current_credit].each do |detail|
        @data["customer_#{detail}".to_sym] = invoicable.respond_to?(detail) ? invoicable.send(detail) : nil
      end

      # Billing Address - Kept at the invoice level for audit purpose
      @data[:customer_billing_address] = @invoice.billing_address

      # Financial values
      @data[:invoice_price] = @invoice.price
      @data[:invoice_currency] = @invoice.price.currency_as_string
      @data[:invoice_currency_name] = @invoice.price.currency.name
      @data[:invoice_credit_paid] = @invoice.credit_paid
      @data[:invoice_total_due] = @invoice.total_due
      @data[:invoice_total_payable] = @invoice.total_payable
      @data[:invoice_tax_payable] = @invoice.tax_payable
      @data[:invoice_tax_pips] = (@invoice.tax_pips_applied || 0)
      @data[:invoice_total_payable_with_tax] = @data[:invoice_total_payable] + @data[:invoice_tax_payable]
      @data[:invoice_fully_paid] = (@data[:invoice_total_payable].zero? || @data[:invoice_total_payable].negative?)

      # Last App billing (Account Situation)
      @data[:invoice_previous_total_due] = @invoice.previous_total_due
      @data[:invoice_previous_total_paid] = @invoice.previous_total_paid

      # Billing details
      @data[:billing_report] = @invoice.billing_summary.map do |item|
        item_label = item[:label]
        price_label = format_price item

        (item[:lines] || []).each do |item_line|
          item_label += "<font size='4'>\n\n</font><font size='8'><color rgb='999999'><i>#{Prawn::Text::NBSP * 3}#{item_line[:label]}</i></color></font>"
          price_label += "<font size='4'>\n\n</font><font size='8'><color rgb='999999'>#{format_price(item_line)}</color></font>"
        end

        [item_label, item[:name], item[:usage], price_label]
      end

      # Billing period
      @data[:period_started_at] = @invoice.started_at.utc.to_date
      @data[:period_ended_at] = (@invoice.ended_at.utc - 1.minute).to_date # '- 1 minute' to avoid midnight (which belongs to following day)
      @data[:period_month] = @invoice.ended_at.strftime("%B")
      next_period = @data[:period_ended_at] + 1.month
      @data[:period_charge_date] = Date.new(next_period.year,next_period.month,2)
    end

    # Render the pdf document and return
    # it as a string object
    def render
      generate_content
      @pdf.render
    end

    def format_price(item)
      # price_tag is deprecated
      price = item[:price]
      if price
        # Money hash are automatically parsed to Money in core/lib/her_extension/middleware/mnoe_api_v1_parse_json.rb
        money(price)
      else
        item[:price_tag]
      end
    end

    # Generate the document content
    # by adding body, header, footer and
    # page numbering
    def generate_content
      @pdf = Prawn::Document.new(
        info: self.metadata,
        top_margin: @format[:header_size] + @format[:top_margin],
        bottom_margin: @format[:footer_size] + @format[:bottom_margin]
      )
      add_page_body
      add_page_header
      add_page_footer
      add_page_numbering
    end

    # Generate the document metadata
    def metadata
      {
        Title: 'Maestrano Monthly Invoice',
        Author: 'Maestrano',
        Subject: 'Maestrano Monthly Invoice',
        Producer: 'Maestrano',
        CreationDate: Time.now
      }
    end

    # Helper method to easily access
    # images
    def image_path(name)
      path = "/app/assets/images/#{name}"
      engine_path = "#{MnoEnterprise::Engine.root}#{path}"
      app_path = "#{Rails.root}#{path}"

      File.exists?(app_path) ? app_path : engine_path
    end

    # Format a money object
    def money(m)
      "#{m.format(symbol: false)} #{m.currency_as_string}"
    end


    # Add a repeated header to the document
    def add_page_header
      @pdf.repeat :all do
        @pdf.bounding_box([0, @pdf.bounds.top+@format[:header_size]], width: 540, height: @format[:footer_size]) do
          @pdf.float do
            @pdf.image image_path('mno_enterprise/main-logo.png'), scale: 0.5
          end
          @pdf.move_down 52
          @pdf.font_size(20) { @pdf.text "Monthly Invoice - #{@data[:period_month]}", style: :bold, align: :right }
        end
      end
    end

    # Add a repeated footer to the document
    def add_page_footer
      @pdf.repeat :all do
        @pdf.bounding_box([0, @pdf.bounds.bottom], width: 540, height: @format[:footer_size]) do
          @pdf.move_down 50
          @pdf.stroke_color '999999'
          @pdf.stroke_horizontal_rule
          @pdf.move_down 10
          @pdf.font_size(8) do
            @pdf.text "<color rgb='999999'>Maestrano is a service of Maestrano Pty Ltd (ABN: 80 152 564 424),</color>", inline_format: true
            @pdf.text "<color rgb='999999'>Suite 102, 410 Elizabeth Street, Surry Hills 2010, Sydney, Australia.</color>", inline_format: true
            @pdf.text "<color rgb='999999'>All charges are in #{@data[:invoice_currency_name]} (#{@data[:invoice_currency]}).</color>", inline_format: true
          end
        end
      end
    end

    # Add page number on every page
    def add_page_numbering
      numbering_options = {
        at: [@pdf.bounds.right - 150, 0-@format[:footer_size]],
        width: 150,
        align: :right,
        start_count_at: 1,
        color: "999999",
        size: 8
      }
      @pdf.number_pages "Page <page> of <total>", numbering_options
    end

    # This method is responsible for
    # generating the actual pdf content
    def add_page_body
      @pdf.stroke_color '999999'

      #===============================
      # Invoice Reference
      #===============================
      @pdf.float do
        original_color = @pdf.fill_color
        @pdf.fill_color "F0F0F0"
        @pdf.fill_rounded_rectangle [310,@pdf.cursor], 230, 50, 5
        @pdf.fill_color = original_color

        @pdf.text_box "Your Reference", at: [310,@pdf.cursor], width: 65, height: 13, align: :center, valign: :center,
          style: :bold_italic, size: 7

        @pdf.text_box @data[:invoice_reference], at: [310,@pdf.cursor], width: 230, height: 50, align: :center, valign: :center,
          style: :bold
      end

      #===============================
      # Customer information
      #===============================
      @pdf.text @data[:customer_name], align: :left, inline_format: true

      if @data[:customer_email]
        @pdf.text "<color rgb='999999'>#{@data[:customer_email]}</color>", align: :left, inline_format: true
      end

      if @data[:customer_billing_address]
        @pdf.move_down 5
        @pdf.text "<color rgb='999999'>#{@data[:customer_billing_address]}</color>", align: :left, inline_format: true, style: :italic, size: 9
      end



      #===============================
      # Summary
      #===============================
      @pdf.move_down 40
      @pdf.font_size(20) { @pdf.text 'Summary', style: :bold }
      @pdf.stroke_horizontal_rule
      @pdf.move_down 10

      summary_data = []
      summary_data << ['Period', 'Total Payable' + (@data[:invoice_tax_pips] > 0 ? "\n<font size='8'><i>(incl. GST)</i></font>" : '')]
      summary_data << ["#{@data[:period_started_at].strftime("%B, %e %Y")} to #{@data[:period_ended_at].strftime("%B, %e %Y")}",money(@data[:invoice_total_payable_with_tax])]

      # Draw Table background
      bg_height = @data[:invoice_tax_pips] > 0 ? 58 : 50
      @pdf.float do
        original_color = @pdf.fill_color
        @pdf.fill_color "d1e17c"
        @pdf.fill_rounded_rectangle [0,@pdf.cursor], 540, bg_height, 5
        @pdf.fill_color = original_color
      end

      # Draw Table
      @pdf.table(summary_data) do |t|
        t.header = true
        t.width = 540
        t.column_widths = [435,105]
        t.cell_style = { borders: [] }
        t.row(0).font_style = :bold

        t.cell_style = { padding: [5, 5, 5, 10], inline_format: true }
        t.cells.style do |c|
          if c.column == 1
            c.align = :center
          end
        end
      end

      @pdf.move_down 10
      @pdf.indent(5) do
        @pdf.font_size(8) do
          @pdf.text "<color rgb='999999'> Charges are all displayed in #{@data[:invoice_currency_name]} (#{@data[:invoice_currency]})</color>", inline_format: true
          if @data[:invoice_fully_paid]
            @pdf.text "<color rgb='999999'>  No credit card payments required for this invoice</color>", inline_format: true
          else
            @pdf.text "<color rgb='999999'>  Your designated credit card will be charged on #{@data[:period_charge_date].strftime("%B,%e %Y")} at midnight UTC</color>", inline_format: true
          end
        end
      end

      #===============================
      # Credit Remaining
      # ---
      # Only if greater than zero
      #===============================
      if @data[:customer_current_credit] && @data[:customer_current_credit].positive?
        @pdf.move_down 5
        @pdf.indent(5) do
          @pdf.font_size(8) do
            @pdf.text "<color rgb='999999'>  Note that your credit is shared with any organization you may have created</color>", inline_format: true
          end
        end

        @pdf.move_up 28

        @pdf.float do
          original_color = @pdf.fill_color
          @pdf.fill_color "67BBE9"
          @pdf.fill_rounded_rectangle [445,@pdf.cursor], 95, 50, 5
          @pdf.fill_color = original_color

          @pdf.text_box "Credit Remaining", at: [445,@pdf.cursor], width: 95, height: 23, align: :center, valign: :center,
            style: :bold, size: 10

          @pdf.text_box money(@data[:customer_current_credit]), at: [445,@pdf.cursor], width: 95, height: 37, align: :center, valign: :bottom
        end

        @pdf.move_down 40
      end

      #========================()=======
      # Account Situation
      #===============================
      @pdf.move_down 30
      @pdf.font_size(20) { @pdf.text 'Account Situation', style: :bold }
      @pdf.stroke_horizontal_rule
      @pdf.move_down 10

      # Situation Data
      situation_data = []
      # Header
      situation_data << [
        '',
        '',
        'Due Last Month',
        '',
        'Paid (Thank You)',
        '',
        'This Month',
        '',
        'Credit',
        '',
        'Total'
      ]

      #Content
      situation_data << [
        '',
        '',
        money(@data[:invoice_previous_total_due]),
        '-',
        money(@data[:invoice_previous_total_paid]),
        '+',
        money(@data[:invoice_price]),
        '-',
        money(@data[:invoice_credit_paid]),
        '=',
        money(@data[:invoice_total_payable])
      ]

      # Draw background
      @pdf.float do
        original_color = @pdf.fill_color
        @pdf.fill_color "F0F0F0"
        @pdf.fill_rounded_rectangle [0,@pdf.cursor], 540, 50, 5
        @pdf.fill_color = original_color
      end


      # Draw left background
      @pdf.float do
        original_color = @pdf.fill_color
        @pdf.fill_color "E0E0E0"
        @pdf.fill_rounded_rectangle [0,@pdf.cursor], 80, 50, 5
        @pdf.fill_color = original_color
        @pdf.move_down 21
        if @data[:invoice_tax_pips] > 0
          @pdf.text_box 'Excl. GST', at: [12,@pdf.cursor]
        else
          @pdf.text_box 'Details', at: [20,@pdf.cursor]
        end
      end

      # Draw table
      @pdf.table(situation_data) do |t|
        t.header = true
        t.width = 540
        t.column_widths = [75,18,75,18,75,18,75,18,75,18,75]
        t.row(0).font_style = :bold
        t.row(0).size = 8
        t.row(0).height = 22
        t.row(1).height = 25

        t.cell_style = {
          borders: [],
          overflow: :shrink_to_fit,
          align: :center
        }

        # Color the '+','-' and '=' characters
        t.cells.style do |c|
          if c.row == 1 && c.column.odd?
            c.text_color = "a8a8a8"
          end
        end
      end


      #=================================
      # Account Situation - Tax Section
      #=================================
      if @data[:invoice_tax_pips] > 0

        #-----------------
        # GST row
        #-----------------
        @pdf.move_down 8

        table_data = []
        table_data << [
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          'GST',
          '+',
          money(@data[:invoice_tax_payable]),
        ]

        # Draw table background
        @pdf.float do
          original_color = @pdf.fill_color
          @pdf.fill_color "F0F0F0"
          @pdf.fill_rounded_rectangle [368,@pdf.cursor], 172, 24, 5
          @pdf.fill_color = original_color
        end

        # Draw left background
        @pdf.float do
          original_color = @pdf.fill_color
          @pdf.fill_color "FAB451"
          @pdf.fill_rounded_rectangle [368,@pdf.cursor], 80, 24, 5
          @pdf.fill_color = original_color
        end

        @pdf.table(table_data) do |t|
          t.header = true
          t.width = 540
          t.column_widths = [75,18,75,18,75,18,75,18,75,18,75]
          t.row(0).height = 25

          t.cell_style = {
            borders: [],
            overflow: :shrink_to_fit,
            align: :center
          }

          # Color the '+','-' and '=' characters
          t.cells.style do |c|
            if c.row == 0 && c.column.odd?
              c.text_color = "a8a8a8"
            end
          end
        end


        #-----------------
        # Total (incl. GST)
        #-----------------
        @pdf.move_down 5

        table_data = []
        table_data << [
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          'Total (incl. GST)',
          '=',
          money(@data[:invoice_total_payable_with_tax]),
        ]

        # Draw table background
        @pdf.float do
          original_color = @pdf.fill_color
          @pdf.fill_color "F0F0F0"
          @pdf.fill_rounded_rectangle [368,@pdf.cursor], 172, 24, 5
          @pdf.fill_color = original_color
        end

        # Draw left background
        @pdf.float do
          original_color = @pdf.fill_color
          @pdf.fill_color "DAE173"
          @pdf.fill_rounded_rectangle [368,@pdf.cursor], 80, 24, 5
          @pdf.fill_color = original_color
        end

        @pdf.table(table_data) do |t|
          t.header = true
          t.width = 540
          t.row(0).font_style = :bold
          t.column_widths = [75,18,75,18,75,18,75,18,75,18,75]
          t.row(0).height = 25

          t.cell_style = {
            borders: [],
            overflow: :shrink_to_fit,
            align: :center
          }

          # Color the '+','-' and '=' characters
          t.cells.style do |c|
            if c.row == 0 && c.column.odd?
              c.text_color = "a8a8a8"
            end
          end
        end

      end


      #===============================
      # Details
      #===============================
      @pdf.start_new_page
      @pdf.font_size(20) { @pdf.text 'Details', style: :bold }
      @pdf.stroke_horizontal_rule
      @pdf.move_down 10

      app_details_data = []
      app_details_data << ['Product', 'Type', 'Usage', 'Price' + (@data[:invoice_tax_pips] > 0 ? "\n<font size='8'><i>(excl. GST)</i></font>" : '')]
      app_details_data += @data[:billing_report]

      @pdf.table(app_details_data) do |t|
        t.header = true
        t.width = 540
        t.row_colors = ["FFFFFF", "F0F0F0"]
        t.column_widths = [240,100,100,100]
        t.cell_style = { borders: [:bottom],
                        border_width: 1,
                        border_color: "999999",
                        inline_format: true
                        }
        t.row(0).borders = [:bottom]
        t.row(0).border_width = 2
        t.row(0).font_style = :bold
      end
    end
  end
end
