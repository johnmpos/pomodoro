# pomodoro.sh
Pomodoro is a technique used to concentrate during your important activities, distributing your time to focus on them and another for a brief break.

This script not only allows you to apply this technique in the simplest way possible but also allows you to block pages or applications just by informing the program of their name in order to increase your focus on your responsibilities

## How to use
Download the script and grant it permissions to run (chmod +x pomodoro.sh). When you run it, it will ask for the name of some websites to monitor while you are using the application, if you add, let's say, YouTube, as soon as you open it it will be identified and the browser will be closed at the same time - if If you do not add any website to be monitored, the script will be terminated (believe me, add at least one that is more distracting)

 When you click 'ok' you will be able to continue writing the names of the sites, as soon as you click 'Cancel' it will go to the pomodoro and request some information such as the focus time you intend to have, the break time and the cycles that you would like to have.

> Desktop applications are also affected, and any pages you visit that contain the exact name of the site you want to avoid (enter only the site name, not the link)
## Dependencies
-- wmctrl [link to wmctrl](https://linux.die.net/man/1/wmctrl)  
> sudo apt-get install wmctrl (ubuntu/debian)

-- zenity [link to zenity](https://help.gnome.org/users/zenity/stable/)
> sudo apt-get install zenity
