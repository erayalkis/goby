require_relative '../util.rb'

class Entity
  def initialize(params = {})
    @name = params[:name] || "Entity"

    @max_hp = hp = params[:max_hp] || 0
    @hp = params[:hp] || hp
    @attack = params[:attack] || 0
    @defense = params[:defense] || 0

    @inventory = params[:inventory] || []
    @gold = params[:gold] || 0

    # Custom battle commands.
    @battle_commands = params[:battle_commands] || []
    # Maintain sorted battle commands.
    @battle_commands.sort!{ |x,y| x.name <=> y.name }

    unless params[:weapon].nil? then params[:weapon].use(self) end
    unless params[:helmet].nil? then params[:helmet].use(self) end

    # This should only be switched to true during battle.
    @escaped = false
  end

  # Adds the specified battle command to the entity's collection.
  def add_battle_command(command)
    @battle_commands.push(command)

    # Maintain sorted battle commands.
    @battle_commands.sort!{ |x,y| x.name <=> y.name }
  end

  # Adds the item and the given amount to the inventory.
  def add_item(item, amount = 1)

    # Increase the amount if the item already exists in the inventory.
    @inventory.each do |couple|
      if (couple.first == item)
        couple.second += amount
        return
      end
    end

    # If not already in the inventory, push a Couple.
    @inventory.push(Couple.new(item, amount))
  end

  # Requires a BattleCommand as the argument.
  # Returns the index of that command, if it exists.
  # Otherwise, returns -1.
  def has_battle_command_by_object(cmd)
    @battle_commands.each_with_index do |command, index|
      if (command == cmd)
        return index
      end
    end
    return -1
  end

  # Requires a String as the argument.
  # Returns the index of that attack, if it exists.
  # Otherwise, returns -1.
  def has_battle_command_by_string(name)
    @battle_commands.each_with_index do |command, index|
      if (command.name.casecmp(name) == 0)
        return index
      end
    end
    return -1
  end

  # Requires an Item as the argument.
  # Returns the index of that item, if it exists.
  # Otherwise, returns -1.
  def has_item_by_object(item)
    inventory.each_with_index do |couple, index|
      if (couple.first == item)
        return index
      end
    end
    return -1
  end

  # Requires a String as the argument.
  # Returns the index of that item, if it exists.
  # Otherwise, returns -1.
  def has_item_by_string(name)
    inventory.each_with_index do |couple, index|
      if (name.casecmp(couple.first.name) == 0)
        return index
      end
    end

    return -1
  end

  # TODO: somehow combine the following two functions using boolean switch?
  # TODO: fix this function.
  def print_attacks_with_stats
    @battle_commands.each do |command|

      # Simple way to check for both damage and success rate attributes.
      # Prevents the name from being displayed for non-attacks.
      unless command.damage.nil?
        puts command.name + "\n  Damage: #{command.damage}"

        unless command.success_rate.nil?
          puts "  Success Rate: #{command.success_rate}"
        end

      end
    end

    print "\n"
  end

  def print_battle_commands
    @battle_commands.each do |command|
      print "❊ " + command.name + "  \n"
    end
    print "\n"
  end

  # Prints the inventory in a nice format.
  def print_inventory
    @inventory.each do |couple|
      puts couple.first.name + " (#{couple.second})"
    end
    print "\n"
  end

  # Prints the status in a nice format.
  def print_status
    puts "HP: #{hp}/#{max_hp}"
    puts "Attack: #{attack}"
    puts "Defense: #{defense}"
    print "\n"

    print "Weapon: "
    if (!@weapon.nil?)
      puts "#{weapon.name}"
    else
      puts "none"
    end

    print "Helmet: "
    if (!@helmet.nil?)
      puts "#{helmet.name}"
    else
      puts "none"
    end

    print "\n"
  end

  # Removes the battle command, if it exists, from the entity's collection.
  def remove_battle_command(command)
    index = has_battle_command_by_object(command)
    if (index >= 0)
      @battle_commands.delete_at(index)
    end
  end

  # Removes the item, if it exists, and, at most,
  # the given amount from the inventory.
  def remove_item(item, amount = 1)

    # Decrease the amount if the item already exists in the inventory.
    @inventory.each_with_index do |couple, index|
      if (couple.first == item)
        couple.second -= amount

        # Delete the item if the amount becomes non-positive.
        if (couple.second <= 0)
          @inventory.delete_at(index)
        end

        return
      end
    end
  end

  def unequip_item_by_string(name)
    if ((!@weapon.nil?) && name.casecmp(@weapon.name) == 0)
      @weapon.unequip(self)
    elsif ((!@helmet.nil?) && name.casecmp(@helmet.name) == 0)
      @helmet.unequip(self)
    else
      print "You are not equipping THAT!\n\n"
    end
  end

  # If the item exists in the Entity's inventory,
  # then it uses the item on Entity e.
  def use_item_by_object(item, e)
    index = has_item_by_object(item)
    if (index != -1)
      actual_item = inventory[index].first
      actual_item.use(e)
      if actual_item.consumable then remove_item(actual_item) end
    else
      print "What?! You don't have THAT!\n\n"
    end
  end

  # If the item exists in the Entity's inventory,
  # then it uses the item on Entity e.
  def use_item_by_string(name, e)
    index = has_item_by_string(name)
    if (index != -1)
      actual_item = inventory[index].first
      actual_item.use(e)
      if actual_item.consumable then remove_item(actual_item) end
    else
      print "What?! You don't have THAT!\n\n"
    end
  end

  def ==(rhs)
    @name == rhs.name
  end

  attr_accessor :name
  attr_accessor :max_hp, :hp
  attr_accessor :attack
  attr_accessor :defense

  # The inventory is stored as an array
  # of Couple objects. The first data type
  # is the item's name. The second data type
  # is its count in the inventory.
  attr_accessor :inventory, :gold

  attr_accessor :weapon
  attr_accessor :helmet

  attr_accessor :battle_commands

  attr_accessor :escaped


end
