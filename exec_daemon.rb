require './bitflyer'
require './slack'

Dotenv.load

SLEEP_TIME = ENV['ORDER_PERIODS']

# デーモン化
class ExecDaemon
  def initialize
    @flag_int = false
    @pid_file = "/tmp/exec_daemon.pid"
    out_file  = "./log/exec_daemon.txt"
    @out_file = File.open(out_file, "w")
  end

  # 起動
  def run
    begin
      @out_file.puts "[START]"
      daemonize
      set_trap
      execute
      @out_file.puts "[E N D]"
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.run] #{e}"
      exit 1
    end
  end

private

  # デーモン化
  def daemonize
    begin
      Process.daemon(true, true)
      open(@pid_file, 'w') {|f| f << Process.pid} if @pid_file
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.daemonize] #{e}"
      exit 1
    end
  end

  # トラップ（割り込み）設定
  def set_trap
    begin
      Signal.trap(:INT)  {@flag_int = true}
      Signal.trap(:TERM) {@flag_int = true} 
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.set_trap] #{e}"
      exit 1
    end
  end

  # 処理実行
  def execute
    begin
      order
      loop do
        break if @flag_int
        sleep SLEEP_TIME.to_i
        order
      end
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.execute] #{e}"
      @out_file.close
      exit 1
    end
  end
end

if ARGV[0] == 'start'
  post_slack 'start deamon'
elsif ARGV[0] == 'end'
  post_slack 'stop deamon'
else
  obj_proc = ExecDaemon.new
  obj_proc.run
end
