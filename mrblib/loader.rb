GlobalIRCache = Hash.new
$damaged_classes = []

def loadIR
    l = Parser.new
    qml_data = [Dir.glob("../mruby-zest/mrblib/*.qml"),
                Dir.glob("../mruby-zest/qml/*.qml"),
                Dir.glob("../mruby-zest/test/*.qml"),
                Dir.glob("../mruby-qml-spawn/test/*.qml"),
                Dir.glob("../mruby-zest/example/*.qml")].flatten
    qml_ir   = Hash.new
    different_file = false
    qml_data.each do |q|
        cname = q.gsub(".qml","").gsub(/.*\//, "")
        hash = File::Stat.new(q).ctime.to_s
        #hash  = `md5sum #{q}`
        q_ir = nil
        if(GlobalIRCache.include?(cname+hash))
            q_ir = GlobalIRCache[cname+hash];
        else
            prog = l.load_qml_from_file(q)
            #puts prog
            root_node = nil
            prog.each do |x|
                if(x.is_a? TInst)
                    root_node = x
                end
            end
            q_ir = ProgIR.new(root_node).IR
            GlobalIRCache[cname+hash] = q_ir
            $damaged_classes << cname
            different_file = true
        end
        qml_ir[cname] = q_ir
    end
    #puts "loadIR with diff = #{different_file}"
    if(different_file)
        qml_ir
    else
        nil
    end
end
