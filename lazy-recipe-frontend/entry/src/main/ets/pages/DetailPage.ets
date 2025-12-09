import { Recipe } from '../model/Recipe';
import router from '@ohos.router';

@Entry
@Component
export struct DetailPage {
  private recipe: Recipe = {
    id: 0,
    title: '',
    ingredients: [],
    taste: '',
    style: '',
    difficulty: '',
    timeMinutes: 0,
    steps: [],
    favorite: false
  };

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      this.recipe = params as Recipe;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
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

        Text('菜谱详情')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Row()
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 8,
        color: '#08000000',
        offsetX: 0,
        offsetY: 2
      })

      Scroll() {
        Column() {
          // 菜谱标题卡片
          Column() {
            Text(this.recipe.title)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            // 标签行
            Row() {
              if (this.recipe.taste && this.recipe.taste !== '') {
                Row() {
                  Text('😋')
                    .fontSize(16)
                  Text(this.recipe.taste)
                    .fontSize(14)
                    .fontColor('#FF6B6B')
                    .margin({ left: 4 })
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#FFE5E5')
                .borderRadius(16)
              }

              if (this.recipe.style && this.recipe.style !== '') {
                Row() {
                  Text('🍽️')
                    .fontSize(16)
                  Text(this.recipe.style)
                    .fontSize(14)
                    .fontColor('#4ECDC4')
                    .margin({ left: 4 })
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#E5F9F7')
                .borderRadius(16)
                .margin({ left: 8 })
              }
            }

            // 信息行
            Row() {
              Column() {
                Text('⏱️')
                  .fontSize(24)
                Text(`${this.recipe.timeMinutes}分钟`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Divider()
                .vertical(true)
                .height(40)
                .color('#EEEEEE')

              Column() {
                Text('📊')
                  .fontSize(24)
                Text(this.recipe.difficulty)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Divider()
                .vertical(true)
                .height(40)
                .color('#EEEEEE')

              Column() {
                Text(this.recipe.favorite ? '❤️' : '🤍')
                  .fontSize(24)
                Text(this.recipe.favorite ? '已收藏' : '未收藏')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 20 })
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16 })
          .shadow({
            radius: 12,
            color: '#15000000',
            offsetX: 0,
            offsetY: 4
          })

          // 所需食材卡片
          Column() {
            Row() {
              Text('🥘')
                .fontSize(20)
              Text('所需食材')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ left: 8 })
            }
            .margin({ bottom: 16 })

            Row() {
              Text(this.recipe.ingredients.join('、'))
                .fontSize(16)
                .fontColor('#666666')
                .lineHeight(26)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F8F9FA')
            .borderRadius(12)
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16 })
          .shadow({
            radius: 12,
            color: '#15000000',
            offsetX: 0,
            offsetY: 4
          })

          // 制作步骤卡片
          Column() {
            Row() {
              Text('👨‍🍳')
                .fontSize(20)
              Text('制作步骤')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ left: 8 })
            }
            .margin({ bottom: 16 })

            ForEach(this.recipe.steps, (step: string, index: number) => {
              Row() {
                // 步骤序号
                Text(`${index + 1}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width(32)
                  .height(32)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#FF6B6B')
                  .borderRadius(16)
                  .margin({ right: 16 })

                // 步骤内容
                Text(step)
                  .fontSize(15)
                  .fontColor('#666666')
                  .lineHeight(24)
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .padding(16)
              .backgroundColor('#F8F9FA')
              .borderRadius(12)
              .margin({ bottom: 12 })
            })
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, bottom: 24 })
          .shadow({
            radius: 12,
            color: '#15000000',
            offsetX: 0,
            offsetY: 4
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}