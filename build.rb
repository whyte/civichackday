#!/usr/bin/env ruby
require 'pry'
require 'aws-sdk'
AWS.config access_key_id: ENV['S3_ACCESS_ID'], secret_access_key: ENV['S3_SECRET_KEY']
s3 = AWS::S3.new
bucket = s3.buckets['ras2013.galaxyzoo.org']

styles = Dir.glob("styles/*.css")
lib    = Dir.glob("lib/**/*")
images = Dir.glob("images/**/*.*")

to_upload = ["index.html"] + styles + lib + images

total = to_upload.count

to_upload.each.with_index do |file, index|
  content_type = case File.extname(file)
  when '.html'
    'text/html'
  when '.js'
    'application/javascript'
  when '.css'
    'text/css'
  when '.gz'
    'application/x-gzip'
  when '.ico'
    'image/x-ico'
  else
    `file --mime-type -b #{ file }`.chomp
  end
  
  puts "#{ '%2d' % (index + 1) } / #{ '%2d' % total }: Uploading #{ file } as #{ content_type }"
  bucket.objects["/"].write file: file, acl: :public_read, content_type: content_type
end


puts 'Done!'
