require 'dropbox_sdk'

access_token = 'mjyTedMka00AAAAAAAAAFJ61ChwdEvtI9wg81Ir81F7bN5HUh4siN8KX_V-tOLMw'
#access token for my (Malcolm's) personal dropbox

@client = DropboxClient.new(access_token)

#Method for printing byte size in the appropriate units and with the appropriate number of decimal places
def display(b)
	if b < 1000
		puts "#{b} bytes"
	elsif b < 1000000
		a = b.to_f
		a = a/1000
		a = a.round(1)
		puts "#{a} kB"
	elsif b < 1000000000
		a = b.to_f
		a = a/1000000
		a = a.round(1)
		puts "#{a} MB"
	elsif b < 1000000000000
		a = b.to_f
		a = a/1000000000
		a = a.round(1)
		puts "#{a} GB"
	else
		a = b.to_f
		a = a/1000000000000
		a = a.round(1)
		puts "#{a} TB"
	end
end

#method to get a list of the paths of the directories in a directory.
def subdir_paths(path)
	folder_metadata = @client.metadata(path)
	contents = folder_metadata['contents']

	subdir_paths = []
	for i in contents
		if i['is_dir']
			subdir_paths << i['path']
		end
	end
	subdir_paths
end

#makes a list of paths, the paths of the contents of a directory
def get_dir_contents(path)
	folder_metadata = @client.metadata(path)
	contents = folder_metadata['contents']

	contents_paths = []
	for i in contents
		contents_paths << i['path']
	end
	contents_paths
end

#recursively sums and returns the bytes in a directory+subdirectories
def get_dir_size(path)
	#get the contents of the directory
	metadata = @client.metadata(path) #a Hash
	contents = metadata['contents'] #an array of Hashs

	@calls += 1
	puts @calls

	#create list of subdirectory paths
	subdirs_list = []
	for i in contents
		if i['is_dir']
			subdirs_list << i['path']
		end
	end

	#size the directory
	size = 0
	contents.each { |entry| size += entry['bytes'] }

	if subdirs_list == []
		return size
	else
		additional_sizes = []
		subdirs_list.each { |dir| additional_sizes << get_dir_size(dir) }
		sum = 0
		additional_sizes.each { |i| sum += i.to_i }
		return size + sum
	end
end

@calls = 0
#gets and prints a directory size
def directory_size(path)
	a = get_dir_size(path)
	display(a)
	@calls = 0
	return a
end

#prints the subdirectories in a directory
def directory_subdirectories(path)
	puts ''
	for i in subdir_paths(path)
		puts i
	end
	puts ''
	return nil
end

#prints the contents of a directory
def directory_contents(path)
	puts ''
	for i in get_dir_contents(path)
		puts i
	end
	puts ''
	return nil
end

#Example file path:  "./folder1"
#Home directory path: "./"
