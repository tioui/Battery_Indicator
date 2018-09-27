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

	set_icon(a_battery:BATTERY_DEVICE)
			-- Change `Current' image using the values in a_battery
		local
			l_icon:EV_PIXEL_BUFFER
		do
			if a_battery.is_critical then
				l_icon := create {BATTERY_CRITICAL_BUFFER}.make
			elseif a_battery.is_very_low then
				l_icon := create {BATTERY_VERY_LOW_BUFFER}.make
			elseif a_battery.is_low then
				l_icon := create {BATTERY_LOW_BUFFER}.make
			elseif a_battery.is_half then
				l_icon := create {BATTERY_HALF_BUFFER}.make
			elseif a_battery.is_high then
				l_icon := create {BATTERY_HIGH_BUFFER}.make
			else
				l_icon := create {BATTERY_FULL_BUFFER}.make
			end
			change_icon(not a_battery.is_discharging, l_icon)
		end

feature {NONE} -- Implementation

	change_icon(a_with_plug:BOOLEAN;a_icon_buffer: EV_PIXEL_BUFFER)
			-- Set the image icon of `Current' using `a_icon_buffer' as source.
		local
			l_pixmap:EV_PIXMAP
		do
			create l_pixmap.make_with_pixel_buffer (a_icon_buffer)
			if a_with_plug then
				l_pixmap.draw_pixmap ((l_pixmap.width // 2) - (plug_pixmap.width // 2), (l_pixmap.height // 2) - (plug_pixmap.height // 2), plug_pixmap)
			end
			set_icon_from_pixmap (l_pixmap)
		end

	plug_pixmap:EV_PIXMAP
			-- Image of the plug.
		local
			l_plug_buffer:PLUG_BUFFER
		once
			create l_plug_buffer.make
			create Result.make_with_pixel_buffer (l_plug_buffer)
		end


end
