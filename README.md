# 1996: My final thesis in compter science at school

1996 was the only school year in which I had computer science lessons. I must have been in the 11th grade. A few friends and I already had a few years of experience with Borland Pascal. While the class was taking its first steps, we were given time off for motivational reasons ;-).

Because I had no other hobbies, this became my final project: the periodic table of the elements, displayed in graphics mode under MS DOS, with two databases I had invented myself. One database was for the chemical elements with their properties, the second for chemical compounds. Both were - of course - only filled with sample data and both are expandable in the program.

Back then, I implemented the graphical dialogs in [CONTROLS.PAS](src/CONTROLS.PAS) in an object-oriented way - I think that was the new cool shit in Pascal at the time. It made it much easier for me to create the many dialogs, but it was also a bit lame. Today you don't notice any of that anymore.

```dos
BPC.EXE -B -CP CHEMIE.PAS
```

![Screenshot of the Code in Action](screenshots/periodensystem_mit_energieniveauschema.jpg)
