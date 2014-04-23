note
	description	: "Descriptor of the battery device protocol."
	author		: "Louis Marchand."
	date		: "2014, april 23"
	revision	: "0.5"

deferred class
	BATTERY_PROTOCOL

feature -- Access

	File_energy_full: STRING = "/sys/class/power_supply/BAT0/energy_full"
			-- The name of the device file to get full energy value

	File_energy_now: STRING = "/sys/class/power_supply/BAT0/energy_now"
			-- The name of the device file to get current energy value

	File_status: STRING = "/sys/class/power_supply/BAT0/status"
			-- The name of the device file to get battery status

	Value_Charging: STRING = "charging"
			-- The value retreive from `File_status' when the battery is charging

	Value_Discharging: STRING = "discharging"
			-- The value retreive from `File_status' when the battery is discharging

	Value_critical: NATURAL_8 = 5
			-- The percentage value when the battery became criticaly low

	Value_very_low: NATURAL_8 = 15
			-- The percentage value when the battery became very low

	Value_low: NATURAL_8 = 35
			-- The percentage value when the battery became low

	Value_half: NATURAL_8 = 65
			-- The percentage value when the battery get to the half

	Value_high: NATURAL_8 = 90
			-- The percentage value when the battery became criticaly low



end
