

[toc]

Last update: 22 sept 2017

## iOS - Jeu de carte basique type Memory


Une démo de jeu de type *Memory* démontrant certains aspects de mes compétences.



Une capture d'écran lors de la distribution de cartes.

![Animation de cartes](medias/card-distrib-anim++.png "Distribution des cartes animée")



Plusieurs éléments de l'IU ont été construits ou configurés avec du code:

- l'UI du deck de cartes: ![le deck](medias/deck-and-card.png "Une carte en train d'être tirée")

  Le fait d'avoir les cartes empilées les unes sur les autres a été codé. Bien sûr, des fonctions et des variables ont été utilisées, ce qui fait que les paramètres tels que l'espacement entre chaque carte, l'emplacement et la taille du deck sont personnalisables.

- les arrondis (celui des cartes et ceux des boutons):

  Les images utilisées pour les cartes possèdent des bords droits. L'arrondi a été fait programmatiquement. De même pour les boutons et la zone de texte.



**Animations et sons**

Afin de rendre le design plus réel, des animations ont été ajoutées.

- Rangement des cartes:

  [Animation] Les cartes sont "ramasées" sur la table de jeu comme on les ramasserait à la main. Le ramassage des cartes est toujours rapide, donc l'animation l'est aussi. Les cartes sont ensuite visuellement insérées dans le deck dans un ordre aléatoire, ce qui donne à l'utilisateur l'impression que le jeu de carte est bien mélangé.

  [Son] Une bande son unique (1 fichier) est utilisé et l'animation se calque sur la durée de celui-ci. Ceci pour démontrer qu'il m'est possible d'ajuster des animations selon les contraintes qui me sont données (dans ce cas, la bande son préétablie)

- Distribution des cartes:

  [Animation] Les cartes sont piochés et distribuées sur le terrain.

  [Son] Cette fois-ci, 1 fichier sonore est rejoué pour chaque carte distribuée. Le son du fichier est court (~1 seconde) et sa vitesse de lecture a été ajustée pour correspondre à la durée pendant laquelle une carte est piochée. En prenant plus de temps pour l'ajustement, on pourrait faire concorder parfaitement l'animation et le son, mais la démo a pour but de montrer un aperçu des possibilités.



![Le plateau de jeu](medias/plateau-de-jeu.png)



Exemple de partie en vidéo

![Une démo](medias/video-demo.mp4)

Compatible: iOS 6 et versions ultérieures

Tags: *iOS*, *Objective-C*, *ARC*
