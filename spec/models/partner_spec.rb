require 'spec_helper'

describe Partner do
  subject { Factory(:partner) }

  it { should respond_to :name }
  it { should validate_presence_of :name }
  it { should have_many(:environments).through(:partner_environment_associations) }
  it { should have_many(:users).through(:partner_user_associations) }

  context "when adding new collaborators" do
    before do
      3.times do
        course = Factory(:course)
        Factory(:partner_environment_association, :partner => subject,
                :environment => course.environment)
      end

      @collaborator = Factory(:user)
      subject.add_collaborator(@collaborator)
    end

    it "creates the correct association to all environments" do
      subject.environments.each do |e|
        e.administrators.should include(@collaborator)
      end
    end

    it "creates the correct association to all courses" do
      courses = subject.environments.collect { |e| e.courses }.flatten

      courses.each do |c|
        c.administrators.should include(@collaborator)
      end
    end

    it "creates the association to partner" do
      subject.users.should include(@collaborator)
    end

    context "when adding duplicated user" do
      it "doesnt change anything on partner admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.should_not change { subject.users }
      end

      it "doesnt change anything on environment admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.should_not change {
          subject.environments.collect { |e| e.administrators }
        }
      end

      it "doesnt change anything on course admins" do
        expect {
          subject.add_collaborator(@collaborator)
        }.should_not change {
          environments = subject.environments
          environments.collect { |e| e.courses }.flatten.collect { |c| c.administrators }
        }
      end



    end
  end

  context "when adding existend environments" do
    before do
      @environment = Factory(:environment)

      @users = 3.times.inject([]) do |acc,i|
        user = Factory(:user)
        subject.add_collaborator(user)
        acc << user
      end
    end

    it "assigns the current collaborators as new environment admins" do
      subject.add_environment(@environment, "12.123.123/1234-12")
      subject.users.to_set.should be_subset(@environment.administrators.to_set)
    end
  end
end
