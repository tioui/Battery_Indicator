note
	description	: "Root class for the battery indicator widget."
	author		: "Louis Marchand."
	date		: "2014, april 23"
	revision	: "0.5"

class
	APPLICATION

inherit
	EV_APPLICATION
		redefine
			create_interface_objects,
			initialize
		end
	INTERFACE_NAMES
		undefine
			default_create,
			copy
		end

create
	make_and_launch

feature {NONE} -- Initialization

	make_and_launch
			-- Initialize and launch application
		do
			default_create
			launch
		end

	create_interface_objects
			-- <Precursor>
		do
			Precursor {EV_APPLICATION}
			create tray_icon.make
		end

	initialize
			-- <Precursor>
		local
			l_battery:BATTERY_DEVICE
		do
			Precursor {EV_APPLICATION}
			create l_battery
			l_battery.on_full_action.extend (agent tray_icon.set_full_icon)
			l_battery.on_high_action.extend (agent tray_icon.set_high_icon)
			l_battery.on_half_action.extend (agent tray_icon.set_half_icon)
			l_battery.on_low_action.extend (agent tray_icon.set_low_icon)
			l_battery.on_very_low_action.extend (agent tray_icon.set_very_low_icon)
			l_battery.on_critical_action.extend (agent tray_icon.set_critical_icon)
			l_battery.on_update.extend (agent tray_icon.set_power_tooltip)
			l_battery.on_critical_action.extend (agent on_low_power)
			tray_icon.activate_action.extend (agent on_click_tray_icon)
			tray_icon.popup_action.extend (agent on_click_tray_icon)
			l_battery.update
		end

feature {NONE} -- Implementation

	tray_icon: POWER_TRAY_ICON
			-- The visual icon to put in the tray bar

	on_click_tray_icon
			-- Called when the user click on the `tray_icon'.
		local
			l_x, l_y:INTEGER
			l_screen:EV_SCREEN
			l_pointer_position:EV_COORDINATE
			l_popup:EV_MENU
			l_about_menu_item:EV_MENU_ITEM
			l_quit_menu_item:EV_MENU_ITEM
			l_env:EXECUTION_ENVIRONMENT
		do
			create l_env
			create l_screen
			l_pointer_position:=l_screen.pointer_position
			l_x:=l_pointer_position.x
			l_y:=l_pointer_position.y
			create l_popup
			create l_about_menu_item.make_with_text_and_action (Menu_about_item, agent show_about)
			l_popup.extend (l_about_menu_item)
			create l_quit_menu_item.make_with_text_and_action (Menu_quit_item, agent destroying)
			l_popup.extend (l_quit_menu_item)
			if l_popup.height+l_y>l_screen.height-40 then
				l_y:=l_y-l_popup.height-40
			end
			if l_popup.width+l_x>l_screen.width-40 then
				l_x:=l_x-l_popup.width-40
			end
			l_popup.show_at (Void, l_x, l_y)
			l_env.sleep (100000000)
		end

	on_low_power
			-- Raise a message to the user when the battery energy became criticaly low.
		local
			l_message_box:EV_MESSAGE_DIALOG
		do
			create l_message_box.make_with_text (Warning_low_battery)
			l_message_box.set_buttons_and_actions (<<Button_ok_item>>, <<agent l_message_box.destroy>>)
			l_message_box.show
			l_message_box.raise
		end

	show_about
			-- Show the program about dialog.
		local
			l_about_dialog:ABOUT_DIALOG
		do
			create l_about_dialog
			l_about_dialog.show
		end

	destroying
			-- Terminate the applicaton.
		do
			tray_icon.destroy
			destroy
		end


end -- class APPLICATION
