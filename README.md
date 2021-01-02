# Godot Measuring Tape

A tool for measuring things in Godot, using the positions of the measurement node and its parent node.

These measurement types are supported:

* Length
* Area
* Perimeter
* Volume
* Surface area

These unit types are supported:

* Meters
* Millimeters
* Centimeters
* Kilometers
* Hammer units (the Source engine's units).
* Inches
* Feet
* Yards
* Miles
* Light seconds
* Light nanoseconds

![3d-1](screenshots/3d-1.png)
![3d-2](screenshots/3d-2.png)
![3d-3](screenshots/3d-3.png)
![3d-4](screenshots/3d-4.png)

With 2D, you can set your own scale using pixels per meter, or PPI/DPI. The
default is 100 pixels per meter, which correlates with Godot's default gravity
setting, but if you are measuring UI elements you may wish to set to your DPI.

![2d-1](screenshots/2d-1.png)
![2d-2](screenshots/2d-2.png)
