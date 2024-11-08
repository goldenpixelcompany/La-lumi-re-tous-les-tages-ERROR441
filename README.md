# La lumière à tous les étages Part-I
*Manuel pour allumer la lumière à tous les étages*

Voici un manuel pour apprendre à allumer la lumière à tous les étages. Et ce n’est pas toujours évident. Surtout lorsque les étages sont longs et grands et que la nature nous attribue une petite taille. Je fais un mètre soixante-neuf et j’avais besoin d’aide. Pour accomplir ma mission, je dû me faire une amie. Mais cette amie n’existait pas et nous l’avons inventée avec d’autres amis.

**Partie I : dispositif**

Nous avons choisi de réaliser cette experience à lécole des arts décoratifs de Paris. Nous étions nombreux à vouloir accomplir cette mission. Voici le batiment concerné avant et après la lumière allumée : 
![facade01](https://github.com/user-attachments/assets/90ce6110-0c9b-44e2-8735-68d82a73356a)

Composée de 441 fenêtres d’un mètre sur un mètre vingt, la baie vitrée de l'école s’étale sur 25 mètres de haut et 21 mètres de large. Chaque fenêtre se transformerait en pixel à l'aide d'un dispositif numérique composé de Leds RGB et de papier. Tous ces dispositifs sont connectés ensembles et forment un écran dit micro-géant : Immense par ses dimensions et minuscule par sa résolution.
![Plan de travail 1](https://github.com/user-attachments/assets/efbce03f-420e-4c89-949c-b8d3a2d4f97f)

**Partie II : Hardware**

POur connecter ces oixels entre eux, nous avons développer un circuit électronique adapté. Chacun d'entre eux controllait 3 pixels. Nous appelions donc les circuits les *métapixels*. Il y avait 147 circuits tous connectés en WIFI et commander par la puce ESP32. Le voici : 


![pcb_blue](https://github.com/user-attachments/assets/cc9eb6c9-5204-4615-831e-f990a0ef07b2)
