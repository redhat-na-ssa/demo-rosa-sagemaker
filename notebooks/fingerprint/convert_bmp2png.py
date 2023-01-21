from PIL import Image
import glob
import os

path_in = '.'
path_out = 'png'

if not os.path.exists(path_out):
    os.makedirs(path_out)

def processImage():
    listing = glob.glob(path_in + '/*.BMP')
    print(listing)
    for infile in listing:
        img = Image.open(path_in+infile)
        name = infile.split('.')
        first_name = path+'/'+name[0] + '.png'

    Image.open(img).resize((96,96)).save(os.path.join(path_out, str(first_name) + '.png'))

processImage