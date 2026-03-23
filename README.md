i am extremely bad at markdown if someone wants to make my readme better go ahead please lol feel free to credit yourself if you do
# ARCHINATOR 
### Sean's Custom Arch Install Script that he made because he was bored. Idk I just want to make my arch install custom but want to be able to install it fast. This isn't really intended for public use but if you want it I'm not stopping you lol. MIT Licence so do whatever you want with it. just give like attribution or something idk
The best arch installer IN THE ENTIRE TRI-STATE AREA /ref

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)  
This project is provided “as is” with no warranty. Use at your own risk.

## Screenshots  

![App Screenshot](https://media.discordapp.net/attachments/1321593674756263957/1481674539984224327/5267d838-5f6f-4637-a91e-d654e62cfefc.png?ex=69b42c72&is=69b2daf2&hm=e11a269fc9722748f894580b46be3149f63748996324694768c3e96d74b22ce0&=&format=webp&quality=lossless)

## Tech Stack  

**LANGUAGE:** ITS LITERALLY ALL BASH. I'M ONLY MAKING THIS BECAUSE I WANT TO LEARN BASH AND IT'S COOL TO MAKE A PROJECT THAT I WILL ACTUALLY STICK WITH.

## Features  

- INSTALL ARCH

## Lessons Learned  

bash. i learned bash. kinda i still suck at it though.

I also learned ai fucking sucks, documentation is way fucking better to diagnose your problems

## INSTALL TO ARCHISO

* First of all make sure you are connected to the internet connectived via an ethernet cable or use [IWCTL](https://man.archlinux.org/man/iwctl.1)

### Install git

* You need git.

~~~
pacman -Sy git
~~~

### Now install archinator to archiso:

Clone the repository
~~~
git clone https://github.com/yvseann/archinator archinator
~~~
Navigate to the repository folder
~~~
cd archinator
~~~
Run the install Script
~~~
./archinator.sh
~~~
Then just follow the instructions on screen.
I am not liable for anything being fucked up.

## Issues

* **No root permissions**: Why do you not have root? You are literally on the archiso. How did this happen? Are you running the script on the archiso? I don't recommend running it on anything else. That might end badly. Run it on the archiso or figure out why you don't have root permissions on the archiso.

* **Secureboot not working**: Have you reset the firmware keys in the bios first?

* **Anything else**: idfk man

only limine works: I haven't implemented the rest yet

I don't get to chose my DE: not yet.

forgot anything? make an issue and maybe fix it for me

## Feedback  

If you have any feedback, please make an issue or something or add me on [discord](https://discord.com/users/820369753981583380)

## License  

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)  
