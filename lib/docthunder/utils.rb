require 'tempfile'
require 'version_sorter'

class DocThunder
  def mkdir_temp
    tf = Tempfile.new('docthunder')
    tpath = tf.path
    tf.unlink
    FileUtils.mkdir_p(tpath)
    puts "* Creating temporary dir #{tpath}"
    tpath
  end

  def mkfile_temp
    tf = Tempfile.new('docurium-index')
    tpath = tf.path
    tf.unlink
    tpath
  end

  def headers
    h = []
    Dir.glob(File.join('**/*.h')).each do |header|
      next if !File.file?(header)
      h << header
    end
    h
  end

  def get_versions
    VersionSorter.sort(git('tag').split("\n"))
  end

  def git(command)
    out = ""
    Dir.chdir(@project_dir) do
      out = `git #{command}`
    end
    out.strip
  end

  def with_git_env(workdir)
    ENV['GIT_INDEX_FILE'] = mkfile_temp
    ENV['GIT_WORK_TREE'] = workdir
    ENV['GIT_DIR'] = File.join(@project_dir, '.git')
    yield
    ENV.delete('GIT_INDEX_FILE')
    ENV.delete('GIT_WORK_TREE')
    ENV.delete('GIT_DIR')
  end

  def checkout(version, workdir)
    with_git_env(workdir) do
      `git read-tree #{version}:#{@project.config.input}`
      `git checkout-index -a`
    end
  end

  def clean_comment(comment)
    comment = comment.gsub(/^\/\//, '')
    comment = comment.gsub(/^\/\**/, '')
    comment = comment.gsub(/^\**/, '')
    comment = comment.gsub(/^[\w\*]*\//, '')
    comment
  end

end
