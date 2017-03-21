control 'Initial test' do
  title 'checking current state'

  describe service 'knotx-main' do
    it { should be_enabled }
    it { should be_running }
  end

  describe service 'knotx-main2' do
    it { should be_enabled }
    it { should be_running }
  end
end

###############################################################################

control 'First init script test' do
  title 'checking instances'

  describe command 'service knotx-main stop' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-main' do
    it { should_not be_running }
  end

  describe service 'knotx-main2' do
    it { should be_running }
  end

  describe bash('ps aux | grep [/]opt/knotx/main/') do
    its('exit_status') { should eq 1 }
  end

  describe bash('ps aux | grep [/]opt/knotx/main2/') do
    its('exit_status') { should eq 0 }
  end

  describe command 'service knotx-main start' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-main' do
    it { should be_running }
  end

  describe service 'knotx-main2' do
    it { should be_running }
  end
end

###############################################################################

control 'Second init script test' do
  title 'checking instances'

  describe command 'service knotx-main2 stop' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-main' do
    it { should be_running }
  end

  describe service 'knotx-main2' do
    it { should_not be_running }
  end

  describe bash('ps aux | grep [/]opt/knotx/main/') do
    its('exit_status') { should eq 0 }
  end

  describe bash('ps aux | grep [/]opt/knotx/main2/') do
    its('exit_status') { should eq 1 }
  end

  describe command 'service knotx-main2 start' do
    its('exit_status') { should eq 0 }
  end

  describe service 'knotx-main' do
    it { should be_running }
  end

  describe service 'knotx-main2' do
    it { should be_running }
  end
end
