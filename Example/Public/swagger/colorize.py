import re
import colorsys

def inverthex(match: re.Match[str]):
    hex = match.group(1)
    RGB = tuple(int(hex[i:i+2], 16) for i in (0, 2, 4))
    HSL = colorsys.rgb_to_hls(*[x/255.0 for x in RGB])
    fRGB = colorsys.hls_to_rgb(HSL[0], 1 - HSL[1], HSL[2])
    nRGB = tuple(int(x*255) for x in fRGB)
    return ':"#%02x%02x%02x"' % nRGB

def inverthex3(match: re.Match[str]):
    hex = match.group(1)
    RGB = tuple(int(hex[i:i+1]+hex[i:i+1], 16) for i in (0, 1, 2))
    HSL = colorsys.rgb_to_hls(*[x/255.0 for x in RGB])
    fRGB = colorsys.hls_to_rgb(HSL[0], 1 - HSL[1], HSL[2])
    nRGB = tuple(int(x*255) for x in fRGB)
    return ':"#%02x%02x%02x"' % nRGB

with open('swagger-ui-bundle.js', 'r+') as file:
    data = file.read()

    data = re.sub(r':"#([0-9a-f]{6})"', inverthex, data)
    data = re.sub(r':"#([0-9a-f]{3})"', inverthex3, data)
    data = re.sub(r':"green', ':"#82ff82', data)
    file.seek(0)
    file.write(data)
    file.truncate()


# def inverthex(match: re.Match[str]):
#     hex = match.group(1)
#     RGB = tuple(int(hex[i:i+2], 16) for i in (0, 2, 4))
#     HSL = colorsys.rgb_to_hls(*[x/255.0 for x in RGB])
#     fRGB = colorsys.hls_to_rgb(HSL[0], 1 - HSL[1], HSL[2])
#     nRGB = tuple(int(x*255) for x in fRGB)
#     return ':#%02x%02x%02x' % nRGB + match.group(2)

# def inverthex3(match: re.Match[str]):
#     hex = match.group(1)
#     RGB = tuple(int(hex[i:i+1]+hex[i:i+1], 16) for i in (0, 1, 2))
#     HSL = colorsys.rgb_to_hls(*[x/255.0 for x in RGB])
#     fRGB = colorsys.hls_to_rgb(HSL[0], 1 - HSL[1], HSL[2])
#     nRGB = tuple(int(x*255) for x in fRGB)
#     return ':#%02x%02x%02x' % nRGB + match.group(2)

# with open('swagger-ui.css', 'r+') as file:
#     data = file.read()

#     data = re.sub(r':#([0-9a-f]{6})([^0-9a-f])', inverthex, data)
#     data = re.sub(r':#([0-9a-f]{3})([^0-9a-f])', inverthex3, data)
#     data = re.sub(r':green', ':#82ff82', data)
#     file.seek(0)
#     file.write(data)
#     file.truncate()
