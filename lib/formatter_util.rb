module FormatterUtil
  
  def self.to_accountingjs(money)
    {
      'value' => money.to_f,
      'options' => {
        'symbol' => money.symbol,
        'decimal' => money.decimal_mark,
        'thousand' => money.thousands_separator,
        'precision' => 2,
        'format' => money.currency.symbol_first ? "%s%v" : "%v%s",
        'subunit_symbol' => money.currency.subunit_symbol,
        'subunit_format' => money.currency.subunit_symbol_first ? "%s%v" : "%v%s",
        'subunit_to_unit' => money.currency.subunit_to_unit
      }
    }
  end
end