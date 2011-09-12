#!/bin/env ruby
## copyright 2011 yannick wurm
## yannick . wurm at unil dot ch
## All rights reserved. If you're making money by using this, you owe me 10%.
##
## Subset a fasta file in ruby using bioruby
##
## DOCUMENTATION: run ./thisScript -h   or check 'doc = ' below


unless RUBY_VERSION == "1.8.7"
  puts "Apologies, #{$1} requires ruby 1.8.7. You are running #{RUBY_VERSION}.\n"
  puts " Well the indexing seemed to be broken on my 1.9.2..."
  puts "An easy way of getting 1.8.7 is by using Ruby Version Manager."
  exit
end


require 'rubygems'
require 'optparse'
require 'logger'
require 'bio'

MY_INDEX_EXTENSION = '.yw_r_idx'

# input: white-space separated list of
#        identifiers, 
#              eg: Sequence1 Sequence2   
#        or identifiers with coordinates
#          eg: seq2:960-2460 seq4:1-1000
# output: array of the same (one per entry)
def read_subset_coords(string_or_file_of_subsets)
  string_of_subsets = ''
  if File.exists?(string_or_file_of_subsets)
    File.open(string_or_file_of_subsets) do |subset_file|
      string_of_subsets = subset_file.read
    end

  else # its just a string
    string_of_subsets = string_or_file_of_subsets
  end

  return string_of_subsets.split(/\s+/)
end

#
# returns revcomp if to < from
# returns fasta format
# supposes bioinformatics-style-coordinates (inclusive, starting at 1)
def subsequence(fasta_string, from, to)
  bioseq = Bio::Sequence.input(fasta_string)
  raise IOError, "Problem with: '#{bioseq.definition}': requested #{from}-#{to} but seq is only" + 
    " #{bioseq.length} long."    if [from,to].max > bioseq.length

  
  seq_id = [bioseq.definition, ':', [from,to].min.to_s, '-', [from,to].max.to_s].join('')

  subseq = ''
  if from <= to
    subseq = bioseq.subseq(from,to)
    
  else
    seq_id += '.revcomp'
    raise IOError, "#{identifier} looks like AA" +
                   "cannot reverse-complement  " if bioseq.guess == Bio::Sequence::AA 
    bioseq.na                                      # this transforms bioseq      
    subseq = (bioseq.subseq(to,from) ).complement  # this is revcomp
  end

  return subseq.to_fasta(seq_id)
end



if __FILE__ == $0  # don't run if loaded for testing


  $log = Logger.new(STDERR)

  
  doc = ["Subset FASTA file based on seq ids and possibly coordinates:\n",
         ' * Coordinates are given as eg: Si_gnF.scaffold06790:221960-223960',
         ' * retreive a whole 1000nt long sequence with "seq" (no coordinates) or "seq:1-1000"',
         ' * if end<start (eg: scaffold1:4300-4000), return reversecomplement (implies DNA).',
         ' * ids should not contain ":" or "-" (Error is Raised)',
         ' * subset FASTA is output to standard err.'
        ].join("\n")

  options = {  }
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{ $0} [options]"  + doc
    
    opts.on("-f", "--fasta input.fasta", 
            "Can be blast output (with result records begining with '>')" + 
            "Or list of IDs (if --ids TRUE)") do |file|
      options[ :input_fasta] = file
    end

    opts.on("-s", "--subset input", 
            "input should be whitespace-delimited identifiers",
            "in the form of a file eg: myids.list",
            'or as a list          eg: "Si_gnF.scaffold00001   Si_gnF.scaffold00003"' ) do |subset|
      options[ :subset] = subset
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end
  
  ### Check arguments are ok ###
  opts.parse!
  [ :input_fasta, :subset].each do |option|
    if options[ option].nil?
      puts "All options required\n" +  opts.help
      exit
    end
  end
  input_fasta = File.expand_path(options[ :input_fasta])
  raise IOError, "Doesnt exist: #{input_fasta}" if !File.exists?(input_fasta)
  

  ########################################
  ### read Ids (and ranges) for subset ### 

  requested_seqs = read_subset_coords(options[ :subset])
  $log.info "#{requested_seqs.length} sequence(s) requested." + 
    "Eg: #{requested_seqs.first(5).join(",")}..."

  ### check they're ok
  model = /^([^:\s]+:\d+-\d+)|([^:\s]+)$/
  
  requested_seqs.each do |request|
    raise ArgumentError, "Weird characters in #{request}'"  unless request.match(model)
    #raise ArgumentError, "Two dashes '-' in '#{request}'"  if request.match(/\-.*\-/) 
    #raise ArgumentError, "Two colons ':' in '#{request}'"  if request.match(/:.*:/)
  end
  $log.info "Requested sequence identifiers look sound."
  
  
  ###############################################
  ### Create FASTA Index if doesn't exist yet ###
  index_file_name = input_fasta + MY_INDEX_EXTENSION

  if File.exists?(index_file_name)
    $log.info "Index exists at #{index_file_name}."  

  else 
    $log.info "Creating index for #{input_fasta} at #{index_file_name}"
    Bio::FlatFileIndex::makeindex(is_bdb  = false, 
                                  dbpath  = index_file_name,
                                  format  = 'fasta',
                                  options = {},
                                  files   = input_fasta )
  end
                                
  
  ###########################################
  ### use index to retreive our sequences ###

  $log.info "Retrieving sequences."
  index = Bio::FlatFileIndex::open(index_file_name)
  num_found_sequences = 0
  requested_seqs.each do |request|
    sequence_id, coordinates = request.split(':')
    fasta_sequence           = index.get_by_id(sequence_id)  # returned as fasta string

    if fasta_sequence == '' or fasta_sequence.nil?
      $log.warn "Not found in #{input_fasta}: '#{sequence_id}'. Requested: '#{request}'."
      next
    end
    
    num_found_sequences += 1
    
    if coordinates.nil?
      bioseq = Bio::Sequence.input(fasta_sequence)
      puts bioseq.to_fasta(bioseq.definition)
      

    else
      from, to = coordinates.split('-')
      from = from.to_i # No need to -1 because subseq is bioinformatics-style
      to   =   to.to_i
      
      puts subsequence(fasta_sequence, from, to)
    end
  end
  $log.info "#{num_found_sequences} sequences output to STDOUT."
  $log.info "Done."
end




