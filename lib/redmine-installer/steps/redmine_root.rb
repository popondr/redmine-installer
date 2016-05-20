require 'find'

module Redmine::Installer::Step
  class RedmineRoot < Base

    CHECK_N_INACCESSIBLE_FILES = 10

    def up
      # Get redmine root
      base.redmine_root ||= ask(:path_for_redmine_root, default: '.')

      # Make absolute path
      base.redmine_root = File.expand_path(base.redmine_root)

      if base.redmine_root == Dir.pwd
        error "You cannot upgrade current dir. Please go to the different directory."
      end

      unless Dir.exist?(base.redmine_root)
        try_create_dir(base.redmine_root)
      end

      unless File.writable?(base.redmine_root)
        error t(:dir_is_not_writeable, dir: base.redmine_root)
      end

      inaccessible_files = []
      Find.find(base.redmine_root).each do |item|
        if !File.writable?(item) || !File.readable?(item)
          inaccessible_files << item
        end

        if inaccessible_files.size > CHECK_N_INACCESSIBLE_FILES
          break
        end
      end

      if inaccessible_files.any?
        error "Redmine root contains inaccessible files. Make sure that all files in #{base.redmine_root} are readable/writeable. (limit #{CHECK_N_INACCESSIBLE_FILES} files: #{inaccessible_files.join(', ')})"
      end
    end

    def save(configuration)
      configuration['redmine_root'] = base.redmine_root
    end

    def load(configuration)
      base.redmine_root = configuration['redmine_root']
    end

  end
end
