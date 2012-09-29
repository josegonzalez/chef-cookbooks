# Create all required directories
[
  "/data/shared",
  "/apps/production",
  "/apps/staging",
  "/apps/production/apps",
  "/apps/staging/apps",
  "/apps/production/apps/current",
  "/apps/staging/apps/current",
]. each do |dir|
  directory dir do
    owner "deploy"
    group "deploy"
    mode  0755
    recursive true
    action :create
    not_if { ::FileTest.directory?(dir) }
  end
end
