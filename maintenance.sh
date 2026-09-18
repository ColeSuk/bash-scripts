#bin/bash
sudo pacman -Syu
yay -Syu
sudo pacman -Rns $(pacman -Qtdq)
sudo pacman -Sc
yay -Sc
