control 'Initial test' do
  title 'checking current state'

  describe service 'knotx-primary' do
    it { should be_enabled }
    it { should be_running }
  end

  describe service 'knotx-secondary' do
    it { should be_enabled }
    it { should be_running }
  end
end

###############################################################################

control 'First init script test' do
  title 'checking instances'

  describe command 'service knotx-primary stop' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-primary' do
    it { should_not be_running }
  end

  describe service 'knotx-secondary' do
    it { should be_running }
  end

  describe bash('ps aux | grep [/]opt/knotx/primary/') do
    its('exit_status') { should eq 1 }
  end

  describe bash('ps aux | grep [/]opt/knotx/secondary/') do
    its('exit_status') { should eq 0 }
  end

  describe command 'service knotx-primary start' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-primary' do
    it { should be_running }
  end

  describe service 'knotx-secondary' do
    it { should be_running }
  end
end

###############################################################################

control 'Second init script test' do
  title 'checking instances'

  describe command 'service knotx-secondary stop' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-primary' do
    it { should be_running }
  end

  describe service 'knotx-secondary' do
    it { should_not be_running }
  end

  describe bash('ps aux | grep [/]opt/knotx/primary/') do
    its('exit_status') { should eq 0 }
  end

  describe bash('ps aux | grep [/]opt/knotx/secondary/') do
    its('exit_status') { should eq 1 }
  end

  describe command 'service knotx-secondary start' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-primary' do
    it { should be_running }
  end

  describe service 'knotx-secondary' do
    it { should be_running }
  end
end
