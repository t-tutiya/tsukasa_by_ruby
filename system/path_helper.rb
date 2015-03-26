#! ruby -E utf-8

#仕様：file_nameにパスが入っている場合、それを削除する
class PathHelper
  #候補パスを格納する配列
  @@path_lists = Array.new

  def self.add_path(path)
    #パスを配列に追加
    @@path_lists << path
  end

  #指定したファイル名のファイルを探索し、相対パスを返す
  #元のファイル名に拡張子がある場合はそれを優先探索する
  #TODO:下とほとんどコードが同じ。かつこっちを使う機会はほぼ無くなる。
  def self.serch_filepath(file_name)
    #拡張子があれば取得
    ext_name = File.extname(file_name)
    #拡張子の有無にかかわらず、それを削除してbasenameを取得
    base_name = File.basename(file_name, ".*")

    #候補ディレクトリを全探査する
    @@path_lists.each do |path|
      #拡張子がある場合、その拡張子で優先探索する
      if ext_name != ""
        #フルパスを作成
        path_name = path + "/" + base_name + ext_name
        #ファイルが存在するなら、そのパスを返す
        return path_name if File.exists?(path_name)
      end

      #拡張子をワイルドカードにしたフルパスを作成
      path_name = path + "/" + base_name + ".*"
      #該当するファイルのリストを取得
      find_paths = Dir.glob(path_name)
      #リストが空で無ければ、一個目を取得ファイルパスとして返す
      return find_paths[0] if !find_paths.empty?
    end

    #ファイルが見つからなければnilを返す
    return nil
  end

  #指定した拡張子のファイルを探索し、相対パスを返す
  #元のファイル名に拡張子がある場合はそれを優先探索する
  #TODO:上とほとんどコードが同じ
  def self.serch_filepath_with_extnames(file_name, ext_name_arr)
    #拡張子があれば取得
    base_ext_name = File.extname(file_name)
    #拡張子の有無にかかわらず、それを削除してbasenameを取得
    base_name = File.basename(file_name, ".*")

    #候補ディレクトリを全探査する
    @@path_lists.each do |path|
      #拡張子がある場合、その拡張子で優先探索する
      if base_ext_name != ""
        #フルパスを作成
        path_name = path + "/" + base_name + base_ext_name
        #ファイルが存在するなら、そのパスを返す
        return path_name if File.exists?(path_name)
      end

      #指定された拡張子でファイルを探索する
      ext_name_arr.each do |ext_name|
        #フルパスを作成
        path_name = path + "/" + base_name + "." + ext_name
        #ファイルが存在するなら、そのパスを返す
        return path_name if File.exists?(path_name)
      end
    end

    #ファイルが見つからなければnilを返す
    return nil
  end

end