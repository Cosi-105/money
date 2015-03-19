class Money
  attr_reader :amount, :currency

  # this means that 1 unit of curr1 has the same value as rate * 1 units of curr2
  def self.add_exchange_rate(curr1, curr2, rate)
    @exchange_rate_table = {} if @exchange_rate_table.nil?
    @exchange_rate_table[ [curr1, curr2] ]  = rate
  end

  def self.convert(amt, curr1, curr2)
    @exchange_rate_table[ [curr1, curr2]] * amt
  end

  def initialize(amount, currency)
    @amount = amount
    @currency = currency
  end

  def +(other)
    if @currency == other.currency
      return Money.new(@amount + other.amount, @currency)
    end

    my_amount_in_new_currency = Money.convert(@amount, @currency, other.currency)
    Money.new(my_amount_in_new_currency + other.amount, other.currency)
  end
  
  def *(other)
    raise Exception, "Can only multiply Money by a number" unless other.class == Fixnum || other.class == Float
    Money.new(@amount * other, @currency)
  end

  def convert_to(new_currency)
    new_amount = Money.convert(@amount, @currency, new_currency)
    Money.new(new_amount, new_currency)
  end
end

require "minitest/autorun"

describe Money do

  it "can represent zero dollars" do
    m = Money.new(0, :dollar)
    m.amount.must_equal 0
    m.currency.must_equal :dollar
  end

  it "Can add money of the same currency" do
    m = Money.new(100, :dollar)
    n = Money.new(200, :dollar)
    sum = m + n
    sum.currency.must_equal :dollar
    sum.amount.must_equal 300
  end

  it "Can multiply an amount by a number" do
    m = Money.new(1000, :dollar)
    product = m * 5
    product.currency.must_equal :dollar
    product.amount.must_equal 5000
  end

  it "Can record exchange rates" do
    Money.add_exchange_rate(:dollar, :euro, 1.1)
    Money.convert(1, :dollar, :euro).must_equal 1.1
  end

  it "Can convert from one unit to another" do
    Money.add_exchange_rate(:dollar, :euro, 1.1)
    doll1000 = Money.new(1000, :dollar)
    euroamount = doll1000.convert_to(:euro)
    euroamount.currency.must_equal :euro
    euroamount.amount.must_equal 1100
  end

  it "Can add amounts of different currencies" do
    Money.add_exchange_rate(:dollar, :euro, 1.1)
    dol = Money.new(1000, :dollar)
    euro = Money.new(1000, :euro)
    sum = dol + euro
    sum.currency.must_equal :euro
    sum.amount.must_equal 2100
  end

  it "Can convert money from euro to dollar also" do
    Money.add_exchange_rate(:dollar, :euro, 1.1)
    dol = Money.new(1000, :dollar)
    euro = Money.new(1000, :euro)
    sum = euro + dol
    sum.currency.must_equal :dollar
    sum.amount.must_equal 1909.09 # actual number according to calculator is 909.090909.... so we will have to consider roundoff
  end

  it "Can convert even if it has to use two different exchange rates" do
    Money.add_exchange_rate(:dollar, :euro, 1.1)
    Money.add_exchange_rate(:btc, :dollar, 300)
    euromoney = Money.new(1000, :euro)
    bitcoinmoney = Money.new(10000, :btc)
    bitcoinsum = euromoney + bitcoinmoney
    bitcoinsum.currency.must_equal :btc
    bitcoinsum.amount.must_equal 1200
  end

  it "Handles unknown currencies in an intelligent way" do
  end

end