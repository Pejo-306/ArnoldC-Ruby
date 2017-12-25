require_relative 'code/arnoldcpm'

unless ARGV.first
  puts 'WARNING: filepath has not been specified.'
end

ArnoldCPM.printer = Kernel
ArnoldCPM.totally_recall do
  File.readlines(ARGV.first).each do |line|
    eval(line)
  end
end

