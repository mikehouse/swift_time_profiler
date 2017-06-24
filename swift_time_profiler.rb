
# call like 'ruby scripName.rb parameters ...'

# parameters:
# -worspace {your workspace}
# -project {your project}
# -scheme {your scheme}
# clean - perform clean before build
# includePods - count Pods dependencies

def find_arg(array, name)
  index = array.index(name)
  index ? array[index + 1] : nil
end

clean = ARGV.include?('clean') ? 'clean' : ''
pods = ARGV.include?('includePods')
scheme = find_arg(ARGV, '-scheme')
workspace = find_arg(ARGV, '-workspace')
project = find_arg(ARGV, '-project')

project_to_build = workspace ? "-workspace #{workspace}" : "-project #{project}"

cmd = "xcodebuild #{project_to_build} -scheme '#{scheme}' OTHER_SWIFT_FLAGS=\"-Xfrontend -debug-time-function-bodies\" build -sdk iphonesimulator -arch x86_64 -configuration Debug #{clean}"
puts cmd
puts ''

timePattern = /^\d+\.\d+ms\s./
podsPattern = /\.\/Pods\/\./

def printTime(ms, line)
  if ms >= 500
    print "\e[31m #{line} \e[0"
  elsif ms >= 100
    print "\e[33m #{line} \e[0"
  elsif ms >= 50
    print "\e[32m #{line} \e[0"
  end
end

IO.popen(cmd).each do |line|
  if line =~ timePattern
    ms = line.split(".").first.to_i
    if pods
      printTime(ms, line)
    else
      unless line =~ podsPattern
        printTime(ms, line)
      end
    end
  end
end
