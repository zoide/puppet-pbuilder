# Ruby snipplet used in jenkins buildstep
# It fetches the package's sources
puts "======> INIT BEGIN <=============="
$url="http://ftp-stud.fht-esslingen.de"
$dget="/usr/bin/dget"
File.exists?($dget) || exit 1
## get the sources
File.read("pbuilder.packages").each_line { |line|
   line.chomp!
   puts "FILE: #{line}"
   puts "URL: #{$url}/#{line}"
   puts %x{$dget -d -u "#{$url}/#{line}.dsc"}
}
