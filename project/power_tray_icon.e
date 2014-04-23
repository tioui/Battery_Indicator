note
	description	: "Represent a tray icon adapt for {BATTERY_DEVICE}."
	author		: "Louis Marchand."
	date		: "2014, april 23"
	revision	: "0.5"

class
	POWER_TRAY_ICON

inherit
	TRAY_ICON
	INTERFACE_NAMES
		undefine
			default_create,
			copy
		end
	EXCEPTIONS
		undefine
			default_create,
			copy
		end

create
	make

feature {NONE} -- Initialisation

	make
			-- Initialization of `Current'
		do
			default_create
			set_title (Tray_title)
		end

feature -- Access

	set_power_tooltip(a_battery:BATTERY_DEVICE)
			-- Update the tooltip of `Current' using data of `a_battery'
		local
			l_state:READABLE_STRING_GENERAL
		do
			l_state:=""
			if a_battery.is_charging then
				l_state:=Tray_tag_charging
			elseif a_battery.is_discharging then
				l_state:=Tray_tag_discharging
			end
			set_tooltip (l_state + a_battery.percentage.out + "%%")
		end

	set_full_icon
			-- Change `Current' image to {BATTERY_FULL}
		do
			change_icon(create {BATTERY_FULL}.make)
		end

	set_high_icon
			-- Change `Current' image to {BATTERY_HIGH}
		do
			change_icon(create {BATTERY_HIGH}.make)
		end

	set_half_icon
			-- Change `Current' image to {BATTERY_HALF}
		do
			change_icon(create {BATTERY_HALF}.make)
		end

	set_low_icon
			-- Change `Current' image to {BATTERY_LOW}
		do
			change_icon(create {BATTERY_LOW}.make)
		end

	set_very_low_icon
			-- Change `Current' image to {BATTERY_VERY_LOW}
		do
			change_icon(create {BATTERY_VERY_LOW}.make)
		end

	set_critical_icon
			-- Change `Current' image to {BATTERY_CRITICAL}
		do
			change_icon(create {BATTERY_CRITICAL}.make)
		end

feature {NONE} -- Implementation

	change_icon(a_icon_buffer: EV_PIXEL_BUFFER)
			-- Set the image icon of `Current' using `a_icon_buffer' as source.
		local
			l_icon_pixmap:EV_PIXMAP
		do
			create l_icon_pixmap.make_with_pixel_buffer (a_icon_buffer)
			set_icon_from_pixmap (l_icon_pixmap)
		end

end
