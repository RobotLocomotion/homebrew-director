cask 'gurobi80' do
  version '8.0.1'
  sha256 '111d5a41c8a67217f6428cda36b6243901c4694698769ed691790cfc4481a9f8'

  url "https://packages.gurobi.com/#{version.major_minor}/gurobi#{version}_mac64.pkg"
  name 'Gurobi Optimizer'
  homepage 'https://www.gurobi.com/products/gurobi-optimizer'

  conflicts_with cask: 'gurobi'

  pkg "gurobi#{version}_mac64.pkg"

  uninstall pkgutil: "com.gurobi.gurobiOptimizer#{version.no_dots}.gurobimac.pkg",
            delete:  [
                       "/Applications/Gurobi #{version}.app",
                       "/Library/gurobi#{version.no_dots}",
                       '/Library/Java/Extensions/gurobi.jar',
                       "/Library/Java/Extensions/libGurobiJni#{version.major_minor.no_dots}.jnilib",
                       '/usr/local/bin/gurobi_cl',
                       '/usr/local/bin/gurobi.env',
                       '/usr/local/bin/gurobi.sh',
                       '/usr/local/lib/gurobi.py',
                       "/usr/local/lib/libgurobi#{version.major_minor.no_dots}.dylib",
                       "/usr/local/lib/libgurobi#{version.major_minor.no_dots}.so",
                       '/Library/Python/2.7/site-packages/gurobipy',
                       "/Library/Python/2.7/site-packages/gurobipy-#{version}-py2.7.egg-info",
                     ]

  caveats do
    files_in_usr_local
    license 'https://www.gurobi.com/pdfs/eula/eula-gurobi.pdf'
  end
end
