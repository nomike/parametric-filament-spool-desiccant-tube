Parametric filament spool desiccant container.

This container can be filled with loose desiccant pearls and placed in the center hole of a filament
spool, to keep it dry during storage.
It has a dense grid of square holes on all sides, which allows air to flow through the container and
reach the desiccant pearls.

The lid can be put on the container and secured by a short twist.

#### Models

As different filament spools have different center hole diameters and widths, there are multiple
models available.

I pre-rendered models for all the filament spool types I have at home right now. If you need any
other, you can generate them with OpenSCAD or the thibgiverse customizer.

| Spool Type | Spool            |
|------------|------------------|
| Type A     | Extrudr 1 kg     |
| Type B     | Extrudr 0.75 kg  |
| Type C     | Prusament 1 kg   |
| Type D     | Prusament 2 kg   |
| Type E     | Polymaker 1 kg   |
| Type F     | Flashforge 1 kg  |
| Type G     | Filaflex 0.5 kg  |

#### Customizing

This design was made in OpenSCAD. The customizer feature on thingiverse is very limited though,
and can´t handle this design. To customize it, head over to GitHub (see link below) and clone the
entire repository (it uses git submodules, so you need to clone with `--recursive`).
You can then open the scad file in OpenSCAD and adjust the parameters to your needs using the
customizer Alternatively you can also manually set parameters in the parameter-json file and run
`make` to generate all STLs.

#### OpenSCAD rendering performance

The rendering performance in OpenSCAD is terrible. Rendering one type can easily take an hour or
more. However. newer versions of OpenSCAD have a new "manifold" backend, which cuts rendering time
down to a fraction of a second.

Unfortunately there hasn't been a release of OpenSCAD since 2021, so you have to get the source from
github and compile it yourself.

In OpenSCAD, go to "Edit" → "Preferences" → "Advanced" and set "3D Rendering" → "Backend" to "Manifold (new/fast)".

#### Thingiverse

<https://thingiverse.com/thing:6961859>

#### GitHub

<https://github.com/nomike/parametric-filament-spool-desiccant-container>
