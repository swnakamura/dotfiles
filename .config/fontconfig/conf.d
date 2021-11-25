<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <description>Force using Japanese font</description>
    <match>
        <test name="lang" compare="contains"><string>en</string></test>
        <edit name="lang" mode="assign" binding="same"><string>ja</string></edit>
    </match>
    <alias>
        <family>serif</family>
        <prefer>
            <family>Hiragino Mincho Pro</family>
        </prefer>
    </alias>
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Hiragino Maru Gothic Pro</family>
            <family>Hiragino Kaku Gothic Pro</family>
        </prefer>
    </alias>
</fontconfig>
