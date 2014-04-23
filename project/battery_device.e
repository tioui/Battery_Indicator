note
	description	: "Represent a battery device."
	author		: "Louis Marchand."
	date		: "2014, april 23"
	revision	: "0.5"

class
	BATTERY_DEVICE

inherit
	BATTERY_PROTOCOL
		undefine
			default_create
		end

	INTERFACE_NAMES
		undefine
			default_create
		end

	EXCEPTIONS
		undefine
			default_create
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Initialization for `Current'.
		local
			l_value:READABLE_STRING_GENERAL
		do
			create on_full_action
			create on_high_action
			create on_half_action
			create on_low_action
			create on_very_low_action
			create on_critical_action
			create on_update
			create timer.make_with_interval (10000)
			l_value := read_line_from_file(File_energy_full,True)
			if l_value.is_natural_64 then
				max_energy := l_value.to_natural_64
			else
				io.put_string (Error_protocol_not_supported + "%N")
				die(4)
			end
			is_full_action_called := False
			is_high_action_called := False
			is_half_action_called := False
			is_low_action_called := False
			is_very_low_action_called := False
			is_critical_action_called := False
		end

feature -- Access

	energy:NATURAL_64
			-- The last updated energy reading. Updated by `update_energy' and `update'.

	update_energy
			-- Update the `energy' value.
		local
			l_value:READABLE_STRING_GENERAL
		do
			l_value := read_line_from_file(File_energy_now,True)
			if l_value.is_natural_64 then
				energy := l_value.to_natural_64
				percentage := ((energy * 100) // max_energy).to_natural_8
			else
				io.put_string (Error_protocol_not_supported + "%N")
				die(4)
			end
		end

	percentage:NATURAL_8
			-- The percentage of remaining `energy'. Updated by `update_energy' and `update'.

	is_charging:BOOLEAN
			-- `Current' is currently in charging state.
		do
			Result := state.as_lower ~ Value_Charging
		end

	is_discharging:BOOLEAN
			-- `Current' is currently in discharging `state'.
		do
			Result := state.as_lower ~ Value_Discharging
		end

	state:READABLE_STRING_GENERAL
			-- A text representing the current `state' of `Current'.
		do
			Result := read_line_from_file(File_status,False)
		end

	is_full:BOOLEAN
			-- `Current' is at it's full  `energy' capacity (or almost)
		do
			Result := percentage > Value_high
		end

	is_high:BOOLEAN
			-- `Current' is high in `energy'
		do
			Result := percentage > Value_half and percentage <= Value_high
		end

	is_half:BOOLEAN
			-- `Current' is at it's half `energy' capacity (or almost)
		do
			Result := percentage > Value_low and percentage <= Value_half
		end

	is_low:BOOLEAN
			-- `Current' is a little low in `energy'
		do
			Result := percentage > Value_very_low and percentage <= Value_low
		end

	is_very_low:BOOLEAN
			-- `Current' is a very low in `energy'
		do
			Result := percentage > Value_critical and percentage <= Value_very_low
		end

	is_critical:BOOLEAN
			-- `Current' `energy' is criticaly low
		do
			Result := percentage <= 5
		end

	max_energy:NATURAL_64
			-- The maximum energy capacity of `Current'

	on_full_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became full.

	on_high_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became high.

	on_half_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became half it's capacity.

	on_low_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became low.

	on_very_low_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became very low.

	on_critical_action:ACTION_SEQUENCE[TUPLE[]]
			-- Called when `Current' `energy' became criticaly low.

	on_update:ACTION_SEQUENCE[TUPLE[battery:like Current]]
			-- When a device reading is done

	update
			-- Read device and update `Current' `energy'
		do
			update_energy
			on_update.call([Current])
			if is_full and not is_full_action_called then
				on_full_action.call ([])
				is_full_action_called := True
			else
				is_full_action_called := False
			end
			if is_high and not is_high_action_called then
				on_high_action.call ([])
				is_high_action_called := True
			else
				is_high_action_called := False
			end
			if is_half and not is_half_action_called then
				on_half_action.call ([])
				is_half_action_called := True
			else
				is_half_action_called := False
			end
			if is_low and not is_low_action_called then
				on_low_action.call ([])
				is_low_action_called := True
			else
				is_low_action_called := False
			end
			if is_very_low and not is_very_low_action_called then
				on_very_low_action.call ([])
				is_very_low_action_called := True
			else
				is_very_low_action_called := False
			end
			if is_critical and not is_critical_action_called then
				on_critical_action.call ([])
				is_critical_action_called := True
			else
				is_critical_action_called := False
			end
		end

feature {NONE} -- Implementation

	timer: EV_TIMEOUT
			-- Used to update `Current' at fixed interval

	is_full_action_called:BOOLEAN
			-- The `on_full_action' has been called once since `is_full' became True

	is_high_action_called:BOOLEAN
			-- The `on_high_action' has been called once since `is_high' became True

	is_half_action_called:BOOLEAN
			-- The `on_half_action' has been called once since `is_half' became True

	is_low_action_called:BOOLEAN
			-- The `on_low_action' has been called once since `is_low' became True

	is_very_low_action_called:BOOLEAN
			-- The `on_very_low_action' has been called once since `is_very_low' became True

	is_critical_action_called:BOOLEAN
			-- The `on_critical_action' has been called once since `is_critical' became True

	read_line_from_file(a_file_name:READABLE_STRING_GENERAL; a_fatal:BOOLEAN):READABLE_STRING_GENERAL
			-- Return the first line of the file whith the name `a_file_name'.
			-- Die with code 3 if `a_fatal' is set
		local
			l_file:PLAIN_TEXT_FILE
		do
			create l_file.make_with_name (a_file_name)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_line
				Result := l_file.last_string
				l_file.close
			else
				Result := ""
				if a_fatal then
					io.put_string (Error_file_not_readable + " (" + a_file_name + ").%N")
					die (3)
				end
			end
		end

end
