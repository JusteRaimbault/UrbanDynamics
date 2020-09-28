


JPGQUALITY=50
PDFRESOLUTION=200
WIDTH=1500
HEIGHT=1000
HORIZONTALPADDING=10
VERTICALPADDING=10

montage circeco.png morphogen.png spatialsens.png urbanevol.png -tile 2x2 -geometry +"$HORIZONTALPADDING"+"$VERTICALPADDING" -resize "$WIDTH"x Dafniblog_Raimbault_Figure.jpg
# -border 2 -bordercolor Black
