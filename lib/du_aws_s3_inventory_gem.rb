require "du_aws_s3_inventory_gem/version"

module DuAwsS3InventoryGem
  class Error < StandardError; end
  # Your code goes here...

  def self.human_readable_byte(byte)
    # Byte, Kilobyte, Megabyte, Gigabyte, Terabyte and Petabyte
    kilo = (byte / (2 ** 10).to_f).round(2)
    mega = (byte / (2 ** 20).to_f).round(2)
    giga = (byte / ( 2 ** 30).to_f).round(2)
    tera = (byte / ( 2 ** 40).to_f).round(2)
    h = {:kilo => kilo, :mega => mega, :giga => giga, :tera => tera, :byte => byte}
    b = byte
    if b < 2 ** 10
      best_unit = 'byte'
    elsif b < 2 ** 20
      best_unit = 'kilo'
    elsif b < 2 ** 30
      best_unit = 'mega'
    elsif b < 2 ** 40
      best_unit = 'giga'
    elsif b < 2 ** 50
      best_unit = 'tera'
    else
      best_unit = nil
    end
    h.update({:best_unit => best_unit})
    unit_display = {:byte => "B", :kilo => "K", :mega => "M", :giga => "G", :tera => "T"}
    #  h[best_unit.intern]
    #  unit_display[h[:best_unit].intern]
    display = sprintf("%6.01f#{unit_display[h[:best_unit].intern]}",   h[best_unit.intern])
    h.update({:display => display})
    return h
  end
  
end
