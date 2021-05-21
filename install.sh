#! /bin/bash
# Installer script for sway-advanced-config
# Developed and maintained by indicozy
# ver: 1.0

function prepareSavedConfigs {
	mkdir -p ~/Documents/sway_configs_saved
	local saved_folders=($(ls -d ~/Documents/sway_configs_saved/YourDefault*))
		for (( i=${#saved_folders[@]}; i>0; i--))
		do
			mv "${saved_folders[$(( i - 1 ))]}" ~/Documents/sway_configs_saved/YourDefault$(( i + 1))
		done

	#update new arrangement of saved folders
	local saved_folders=($(ls -d ~/Documents/sway_configs_saved/YourDefault*))

		for (( i=${#saved_folders[@]}; i>7; i--)) #removes old folers up to 7+1 (1 is newly created) folder
		do
			rm -r ${saved_folders[$(($i - 1))]}
		done
}

function autoAppend {
	echo "######[Auto-Appended] Theme switch script

bindsym
{
	Mod4+Ctrl+1 exec $path/changetheme.sh 1 
	Mod4+Ctrl+2 exec $path/changetheme.sh 2
	Mod4+Ctrl+3 exec $path/changetheme.sh 3 
	Mod4+Ctrl+4 exec $path/changetheme.sh 4 
	Mod4+Ctrl+5 exec $path/changetheme.sh 5 
	Mod4+Ctrl+6 exec $path/changetheme.sh 6 
	Mod4+Ctrl+7 exec $path/changetheme.sh 7 
	Mod4+Ctrl+8 exec $path/changetheme.sh 8 
	Mod4+Ctrl+9 exec $path/changetheme.sh 9
	Mod4+Ctrl+left exec $path/changetheme.sh prev
	Mod4+Ctrl+right exec $path/changetheme.sh next
	Mod4+Ctrl+Space exec $path/changetheme.sh
	Mod4+Ctrl+s exec $path/changetheme.sh save

}
" >> ~/.config/sway/config
}

function backupConfig {
	local backupfolders=(alacritty mako nwg-dock nwg-launchers nwg-panel rofi sway swaylock waybar wlogout zathura) 
	for i in "${backupfolders[@]}"
	do
		mkdir -p ~/Documents/sway_configs_saved/YourDefault/$i > /dev/null
		cp -r ~/.config/$i/* ~/Documents/sway_configs_saved/YourDefault/$i/
	done
}

function installSwitcher {
	mkdir $path 2> /dev/null
	cd $git_path
	cp -r configs changetheme.sh install.sh LICENSE README.md $path
}

function installApplications {

	if dialog --title "Install Packages" \
		--yesno "Do you want to install necessary packages first?" 7 50
	then
	dialog --title "Note"\
		--msgbox "Some applications need to be installed by hand. Please check README.md on topic of 'Building from Source'" 10 50
		clear
		#add in future sgtk-menu (no theme is using, AUR), nwg-menu (Code), hybridbar (Code), nwg-panel (no theme is using, Code), azote (no theme is using, AUR)
		sudo pacman -S --needed alacritty mako rofi sway zathura zenity 
		yay -S --needed swaylock-effects rofi-lbonn-wayland-git wlogout nwg-launchers
		echo "Packages are installed, now insalling the script..."
		sleep 1
	else
		clear
		echo "You chose not to install packages."
	fi
}

function distroIsArch {
	if ! cat /etc/*-release | grep Arch\ Linux > /dev/null
	then
		return 1
	fi
	return 0
}

function checkPackageManager {
	if distroIsArch; then
		installApplications
	else
		echo "Sorry, but your distro is not Arch linux (or script could not find your distro)\nPlease contact me at github.com/indicozy to submit your distro"
	fi
}



####### MAIN


if dialog --title "Install Theme Changer" \
	--yesno "Would you like to install the Theme Changer?\nPlease check if you installed all dependencies first" 10 50
then

	git_path=($(pwd))
	echo $git_path
	if ! [[ "$git_path" == *"sway-advanced-config" ]]; then
		echo "ERROR: Most likely you are installing from the wrong folder, please check my github: https://github.com/indicozy/sway-advanced-config"
		exit
	fi

	path=~/.sway-advanced-config

	checkPackageManager

	prepareSavedConfigs

	backupConfig

	installSwitcher

	autoAppend

	swaymsg reload

	notify-send "You are ready to go!" "Just click Ctrl+Super+Space"

	dialog --title "Installation Complete"\
		--msgbox "Your previous theme before installation was saved in ~/Documents/sway_configs_saved/YourDefault\n\n\n     Just click Ctrl+Super+Space to start!" 10 50


else
	clear
	echo "You chose not to install. No files has been changed."
fi
