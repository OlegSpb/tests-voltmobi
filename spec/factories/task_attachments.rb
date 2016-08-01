FactoryGirl.define do
  factory :task_attachment do

    sequence(:file) do
      if rand(10).odd?
        Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'img.png'))
      else
        Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'files', 'doc.docx'))
      end
    end

    task
  end
end
