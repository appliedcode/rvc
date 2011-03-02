include RVC::Util

# TODO windows tmp folder
def _local_vmrc_dir ver
  File.join("/tmp", "vmrc-#{Process::UID.eid}-#{ver}")
end

def _find_local_vmrc
  ver = $vim.serviceInstance.content.about.version
  path = File.join(_local_vmrc_dir(ver), 'plugins', 'vmware-vmrc')
  File.exists?(path) && path
end

def _find_vmrc
  @cached_vmrc ||= ENV['VMRC'] || _find_local_vmrc || search_path('vmrc')
end

def _clear_cached_vmrc
  @cached_vmrc = nil
end

def view *paths
  err "VMRC not found" unless _find_vmrc
  paths.each do |path|
    obj = lookup path
    expect obj, VIM::VirtualMachine
    moref = obj._ref
    fork do
      ENV['https_proxy'] = ENV['HTTPS_PROXY'] = ''
      $stderr.reopen("#{ENV['HOME']||'.'}/.rvc-vmrc.log", "w")
      Process.setpgrp
      exec _find_vmrc, '-M', moref, '-h', $opts[:host], '-u', $opts[:user], '-p', $opts[:password]
    end
  end
end