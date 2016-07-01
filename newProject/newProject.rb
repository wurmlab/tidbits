#!/usr/bin/env ruby 
### copyright: yannick wurm
### author:    yannick dot wurm at insalien dot org                             http://yannick.poulet.org
### created:   2010
### revised:   2013
###
### aim:    create folder hierarchy with:
###           projectName/doc
###           projectName/results
###           projectName/results/currentDate-subProject
###           projectName/data
###           projectName/data/currentDate-subProject
###
###         and text files:
###           projectName/results/getResults.rb
###           projectName/doc/WHATIMDOING.txt
###
###         and creates a soft link from within results/currentDate-subProject to relevant data folder.

require 'main'
require 'fileutils'

Main  { 
  argument('projectName') {
    required  
    description 'We need a project name'
    validate    { |name| name.length >0 }  # and no path characters!
  }
  argument('subProject') {
    required
    description 'We need a subproject name'
    validate    { |name| name.length >0 }
  }
  
  def run
    today         = [Time.now.year, "%02d" % Time.now.month, "%02d" % Time.now.day].join('-')
    subProject    = today + '-' + params['subProject' ].value
    projectDir    = today + '-' + params['projectName'].value
    
    relativeDirPaths = {
      :docs    => 'doc/',
      :data    => File.join('data',    subProject),
      :results => File.join('results', subProject),
      :soft    => 'soft/'
    }
    
    completeDirPaths = relativeDirPaths.clone 
    completeDirPaths.keys.each { |dir| completeDirPaths[dir] = File.join(projectDir, completeDirPaths[dir]) }

    completeDirPaths.keys.each do |dir|
      FileUtils.mkdir_p(completeDirPaths[dir])
      self.info('Created: '+ completeDirPaths[dir])
    end

    FileUtils.ln_s( File.join("../../", relativeDirPaths[:data]), File.join(completeDirPaths[:results], "input"))
    self.info('Linked data dir.')


    self.info('Please be sure to create WHATIDID.txt (or .md or .Rmd or .sh) files at appropriate levels')
#    FileUtils.cp(File.expand_path('~/src/templates/getResults.rb'),   completeDirPaths[:results])
#    FileUtils.cp(File.expand_path('~/src/templates/WHATIDID.md'), completeDirPaths[:docs])
#    self.info('Created getResults.rb and WHATIMDOING.txt')
  end
}
