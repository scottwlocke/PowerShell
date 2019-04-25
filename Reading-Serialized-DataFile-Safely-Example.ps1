# Create a test PSD1 file
@'
    @{
        a1 = 'a1'
        a2 = 2
        a3 = @{
          b1 = 'b1 value'
          c1 = 'another string'
        }
    }
'@ | Set-Content -Path .\example.psd1

# Read the file, put into Data variable
Import-LocalizedData  -FileName example.psd1 -BindingVariable Data


# Use the data
$Data.a1
$Data.a3.b1