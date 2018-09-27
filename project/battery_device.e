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

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Initialization for `Current'.
		local
			l_value:READABLE_STRING_GENERAL
		do
			last_state := "~"
			create on_full_action
			create on_high_action
			create on_half_action
			create on_low_action
			create on_very_low_action
			create on_critical_action
			create on_update
			create on_state_change_action
			create timer.make_with_interval (1000)
			timer.actions.extend (agent update)
			l_value := read_line_from_file(File_energy_full,True)
			if l_value.is_natural_64 then
				max_energy := l_value.to_natural_64
			else
				io.put_string (Error_protocol_not_supported + "%N")
				(create {EXCEPTIONS}).die(1)
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
				(create {EXCEPTIONS}).die(2)
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
			Result := percentage <= value_critical
		end

	max_energy:NATURAL_64
			-- The maximum energy capacity of `Current'

	on_full_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became full.

	on_high_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became high.

	on_half_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became half it's capacity.

	on_low_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became low.

	on_very_low_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became very low.

	on_critical_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `energy' became criticaly low.

	on_state_change_action:ACTION_SEQUENCE[TUPLE]
			-- Called when `Current' `state' change.

	on_update:ACTION_SEQUENCE[TUPLE[battery:like Current]]
			-- When a device reading is done

	update
			-- Read device and update `Current' `energy'
		local
			l_retry_count:INTEGER
		do
			l_retry_count := 1
			if l_retry_count <=3 then
				update_energy
				on_update.call([Current])
				check_for_full_state
				check_for_high_state
				check_for_half_state
				check_for_low_state
				check_for_very_low_state
				check_for_critical_state
				check_for_state_change
			else
				(create {EXCEPTIONS}).die (3)
			end
		rescue
			l_retry_count := l_retry_count + 1
			retry
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

	last_state:READABLE_STRING_GENERAL
			-- The last `state' value that the `on_state_change_action' has been called for.

	read_line_from_file(a_file_name:READABLE_STRING_GENERAL; a_fatal:BOOLEAN):READABLE_STRING_GENERAL
			-- Return the first line of the file whith the name `a_file_name'.
			-- Die with code 4 on error if `a_fatal' is set
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
					(create {EXCEPTIONS}).die(4)
				end
			end
		end

	check_for_state_change
		local
			l_state:like state
		do
			l_state := state
			if not l_state.is_equal (last_state) then
				on_state_change_action.call ([])
				last_state := l_state
			end
		end

	check_for_full_state
			-- Confirm that `Current' is in full power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_full then
				if not is_full_action_called then
					on_full_action.call ([])
					is_full_action_called := True
				end
			else
				is_full_action_called := False
			end
		end

	check_for_high_state
			-- Confirm that `Current' is in high power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_high then
				if not is_high_action_called then
					on_high_action.call ([])
					is_high_action_called := True
				end
			else
				is_high_action_called := False
			end
		end

	check_for_half_state
			-- Confirm that `Current' is in half power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_half then
				if not is_half_action_called then
					on_half_action.call ([])
					is_half_action_called := True
				end
			else
				is_half_action_called := False
			end
		end

	check_for_low_state
			-- Confirm that `Current' is in low power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_low then
				if not is_low_action_called then
					on_low_action.call ([])
					is_low_action_called := True
				end
			else
				is_low_action_called := False
			end
		end

	check_for_very_low_state
			-- Confirm that `Current' is in very low power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_very_low then
				if not is_very_low_action_called then
					on_very_low_action.call ([])
					is_very_low_action_called := True
				end
			else
				is_very_low_action_called := False
			end
		end

	check_for_critical_state
			-- Confirm that `Current' is in critical power state and call the
			-- callback `on_full_action' if it has not been already called.
		do
			if is_critical then
				if not is_critical_action_called then
					on_critical_action.call ([])
					is_critical_action_called := True
				end
			else
				is_critical_action_called := False
			end
		end


end
