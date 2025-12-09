import router from '@ohos.router';

@Entry
@Component
export struct HistoryPage {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor('#666666')
          Text('返回')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .onClick(() => {
          router.back();
        })

        Blank()

        Text('浏览历史')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Row().width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 8, color: '#08000000', offsetY: 2 })

      // 内容区（空白占位）
      Column() {
        Text('📜')
          .fontSize(64)
        Text('暂无历史记录')
          .fontSize(18)
          .fontColor('#999999')
          .margin({ top: 16 })
        Text('快去浏览你感兴趣的菜谱吧～')
          .fontSize(14)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}
