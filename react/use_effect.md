useEffect(() => {

}, []);
基本的には上記のような使い方をする。
第二引数の配列の中がから文字だと、ページが最初に読み込まれたときのみアロー関数内の処理を実行する。なので、サーバーサイドからデータを取ってくる時なんかに使われる。再レンダリングの度にデータを取ってきていては処理が重くなるので、パフォーマンスの向上につなげることができる。
一方配列の中に変数を入れると、その変数にのみ関心を持つuseEffectになる。つまり、その変数の値が変化した時のみ中のアロー関数内の処理が実行されるようになる。例えば、numberという変数があったとして、それを第二引数の配列の中に入れると、numberが変化した時のみ中の処理が実行される。