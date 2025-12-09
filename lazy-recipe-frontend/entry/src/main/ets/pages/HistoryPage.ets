// import router from '@ohos.router';
//
// @Entry
// @Component
// export struct HistoryPage {
//   build() {
//     Column() {
//       // 顶部导航栏
//       Row() {
//         Row() {
//           Text('←')
//             .fontSize(24)
//             .fontColor('#666666')
//           Text('返回')
//             .fontSize(16)
//             .fontColor('#666666')
//             .margin({ left: 4 })
//         }
//         .onClick(() => {
//           router.back();
//         })
//
//         Blank()
//
//         Text('浏览历史')
//           .fontSize(22)
//           .fontWeight(FontWeight.Bold)
//           .fontColor('#333333')
//
//         Blank()
//
//         Row().width(60)
//       }
//       .width('100%')
//       .height(56)
//       .padding({ left: 20, right: 20 })
//       .backgroundColor('#FFFFFF')
//       .shadow({ radius: 8, color: '#08000000', offsetY: 2 })
//
//       // 内容区（空白占位）
//       Column() {
//         Text('📜')
//           .fontSize(64)
//         Text('暂无历史记录')
//           .fontSize(18)
//           .fontColor('#999999')
//           .margin({ top: 16 })
//         Text('快去浏览你感兴趣的菜谱吧～')
//           .fontSize(14)
//           .fontColor('#CCCCCC')
//           .margin({ top: 8 })
//       }
//       .width('100%')
//       .height('100%')
//       .justifyContent(FlexAlign.Center)
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor('#F8F9FA')
//   }
// }
import { Recipe } from '../model/Recipe'
import { ApiService } from '../common/ApiService'
import router from '@ohos.router'

@Entry
@Component
export struct HistoryPage {
  @State recipes: Recipe[] = []
  @State isLoading: boolean = false

  aboutToAppear() {
    this.loadHistory()
  }

  private async loadHistory() {
    this.isLoading = true
    try {
      const data = await ApiService.getHistory()
      this.recipes = data
    } catch (e) {
      console.error('加载历史记录失败', e)
    } finally {
      this.isLoading = false
    }
  }

  private async toggleFavorite(recipeId: number) {
    const currentRecipe = this.recipes.find(r => r.id === recipeId);
    if (!currentRecipe) return;

    try {
      const newFavoriteState = !currentRecipe.favorite;
      const updatedRecipes: Recipe[] = this.recipes.map((r: Recipe): Recipe => {
        if (r.id === recipeId) {
          return {
            id: r.id,
            title: r.title,
            ingredients: r.ingredients,
            taste: r.taste,
            style: r.style,
            timeMinutes: r.timeMinutes,
            difficulty: r.difficulty,
            steps: r.steps,
            favorite: newFavoriteState,
            lastViewedAt: r.lastViewedAt
          };
        }
        return r;
      });
      this.recipes = updatedRecipes;

      await ApiService.updateFavorite(recipeId);

    } catch (error) {
      console.error('更新收藏失败:', error);

      const rollbackRecipes: Recipe[] = this.recipes.map((r: Recipe): Recipe => {
        if (r.id === recipeId) {
          return {
            id: r.id,
            title: r.title,
            ingredients: r.ingredients,
            taste: r.taste,
            style: r.style,
            timeMinutes: r.timeMinutes,
            difficulty: r.difficulty,
            steps: r.steps,
            favorite: currentRecipe.favorite,
            lastViewedAt: r.lastViewedAt
          };
        }
        return r;
      });
      this.recipes = rollbackRecipes;
    }
  }

  private navigateToDetail(recipe: Recipe) {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: recipe
    })
  }

  private formatTime(dateStr: string): string {
    if (!dateStr) return '';

    try {
      // 解析日期字符串
      const date = new Date(dateStr);
      const now = new Date();
      const diff = now.getTime() - date.getTime();

      const minutes = Math.floor(diff / 60000);
      const hours = Math.floor(diff / 3600000);
      const days = Math.floor(diff / 86400000);

      if (minutes < 1) return '刚刚';
      if (minutes < 60) return `${minutes}分钟前`;
      if (hours < 24) return `${hours}小时前`;
      if (days < 7) return `${days}天前`;

      // 超过7天显示具体日期
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${month}月${day}日`;
    } catch (e) {
      return '';
    }
  }

  @Builder
  buildRecipeCard(r: Recipe) {
    Column() {
      Row() {
        Column() {
          Text(r.title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(`难度：${r.difficulty}`)
              .fontSize(15)
              .fontColor('#666666')

            Text('|')
              .fontSize(15)
              .fontColor('#DDDDDD')
              .margin({ left: 8, right: 8 })

            Text(`${r.timeMinutes}分钟`)
              .fontSize(15)
              .fontColor('#666666')
          }.margin({ top: 8 })

          Row() {
            if (r.taste && r.taste !== '') {
              Text(r.taste)
                .fontSize(12)
                .fontColor('#FF6B6B')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#FFE5E5')
                .borderRadius(4)
            }
            if (r.style && r.style !== '') {
              Text(r.style)
                .fontSize(12)
                .fontColor('#4ECDC4')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#E5F9F7')
                .borderRadius(4)
                .margin({ left: 6 })
            }

            // ✅ 显示浏览时间
            if (r.lastViewedAt) {
              Text(`🕐 ${this.formatTime(r.lastViewedAt)}`)
                .fontSize(12)
                .fontColor('#999999')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#F5F5F5')
                .borderRadius(4)
                .margin({ left: 6 })
            }
          }.margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick(() => this.navigateToDetail(r))

        Column() {
          Text(r.favorite ? "❤️" : "🤍")
            .fontSize(32)
          Text(r.favorite ? "已收藏" : "收藏")
            .fontSize(13)
            .margin({ top: 4 })
            .fontColor(r.favorite ? '#FF6B6B' : '#999999')
        }
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 8 })
        .onClick(() => {
          this.toggleFavorite(r.id);
        })
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 12, color: '#15000000', offsetX: 0, offsetY: 4 })
  }

  build() {
    Column() {
      // 顶部栏
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
        .onClick(() => router.back())

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
      .shadow({ radius: 8, color: '#08000000', offsetX: 0, offsetY: 2 })

      // 内容区
      if (this.isLoading) {
        Column() {
          Text("⏳")
            .fontSize(48)
          Text("正在加载浏览历史...")
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.recipes.length === 0) {
        Column() {
          Text("📜")
            .fontSize(64)
          Text("暂无浏览记录")
            .fontSize(18)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text("快去看看有什么好吃的吧～")
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 统计信息
          Row() {
            Text(`最近浏览了 `)
              .fontSize(15)
              .fontColor('#666666')
            Text(`${this.recipes.length}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4ECDC4')
            Text(` 道菜谱`)
              .fontSize(15)
              .fontColor('#666666')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 8 })

          // 菜谱列表
          Scroll() {
            Column() {
              ForEach(this.recipes, (r: Recipe, i: number) => {
                Column() {
                  this.buildRecipeCard(r)
                }
              }, (r: Recipe, i: number) => `${i}-${r.id}-${r.favorite}`)
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .align(Alignment.Top) // ✅ 从顶部对齐
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}