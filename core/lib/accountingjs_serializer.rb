module AccountingjsSerializer

  def self.serialize(money)
    {
      'value' => money.to_f,
      'options' => {
        'symbol' => money.symbol,
        'decimal' => money.decimal_mark,
        'thousand' => money.thousands_separator,
        'precision' => 2,
        'format' => money.currency.symbol_first ? "%s%v" : "%v%s",
        'subunit_symbol' => subunit_symbol(money.currency),
        'subunit_format' => subunit_symbol_first(money.currency) ? "%s%v" : "%v%s",
        'subunit_to_unit' => money.currency.subunit_to_unit,
        'iso_code' => money.currency_as_string
      }
    }
  end

  # Return whether the subunit symbol
  # should be first or not
  def self.subunit_symbol_first(currency)
    if currency.id == :cny
      return true
    else
      return false
    end
  end

  # Return the symbol of the
  # subunit
  def self.subunit_symbol(currency)
    if currency.subunit
      subunit_label = currency.subunit.downcase

      if subunit_label =~ /cent/i && currency.iso_code == 'EUR'
        subunit_label = 'ct'
      elsif subunit_label =~ /cent/i
        subunit_label = 'c'
      elsif subunit_label =~ /penny/i
        subunit_label = 'p'
      elsif subunit_label =~ /fen/i
        subunit_label = 20998.chr
      end

      return subunit_label
    else
      return nil
    end
  end
end
