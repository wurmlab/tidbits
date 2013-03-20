#!/bin/env ruby 
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


require 'rubygems'
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
  
  
  DocDir        = 'docs'
  DataSubDir    = 'dataSub'
  ResultsSubDir = 'resultsSub'
  
  def run
    today         = [Time.now.year, "%02d" % Time.now.month, "%02d" % Time.now.day].join('-')
    subProject    = today + '-' + params['subProject' ].value
    projectDir    = today + '-' + params['projectName'].value
    
    relativeDirPaths = {
      DocDir        => 'doc/',
      DataSubDir    => File.join('data',    subProject),
      ResultsSubDir => File.join('results', subProject)
    }
    
    completeDirPaths = relativeDirPaths.clone 
    completeDirPaths.keys.each { |dir| completeDirPaths[dir] = File.join(projectDir, completeDirPaths[dir]) }

    completeDirPaths.keys.each do |dir|
      FileUtils.mkdir_p(completeDirPaths[dir])
      self.info('Created: '+ completeDirPaths[dir])
    end

    FileUtils.ln_s( File.join("../../", relativeDirPaths[DataSubDir]), File.join(completeDirPaths[ResultsSubDir], "data"))
    self.info('Linked data dir.')

    FileUtils.cp(File.expand_path('~/src/templates/getResults.rb'),   completeDirPaths[ResultsSubDir])
    FileUtils.cp(File.expand_path('~/src/templates/WHATIMDOING.txt'), completeDirPaths[DocDir])
    self.info('Created getResults.rb and WHATIMDOING.txt')
  end
}
