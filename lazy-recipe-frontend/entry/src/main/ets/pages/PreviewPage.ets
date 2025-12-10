import { ApiService } from '../common/ApiService';
import { Recipe } from '../model/Recipe';
import router from '@ohos.router';

@Entry
@Component
export struct PreviewPage {

  @State isLoading: boolean = false;
  @State recipes: Recipe[] = [];

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
            favorite: newFavoriteState
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
            favorite: currentRecipe.favorite
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
    });
  }

  async aboutToAppear() {
    this.isLoading = true;
    try {
      this.recipes = await ApiService.getLatestRecipes();
    } catch (e) {
      console.error("今日推荐加载失败:", e);
      this.recipes = [];
    } finally {
      this.isLoading = false;
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
          }
          .margin({ top: 8 })

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
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick(() => this.navigateToDetail(r))

        Column() {
          Text(r.favorite ? "❤️" : "🤍")
            .fontSize(24)
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
    .shadow({
      radius: 12,
      color: '#15000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  build() {
    Column() {

      // 顶部标题栏（与 HomePage 风格统一）
      Row() {
        Column() {
          Text('懒人食谱助手')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('发现美食，享受生活')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 40, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 8, color: '#08000000', offsetY: 2 })

      Scroll() {
        Column() {

          // 今日推荐标题
          Text("🍽 今日推荐")
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor("#333333")
            .width("100%")
            .margin({ top: 24, bottom: 14, left: 4 })

          // 加载中
          if (this.isLoading) {
            Column() {
              Text("⏳")
                .fontSize(48)
              Text("正在加载今日推荐...")
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 })
            }
            .width("100%")
            .padding({ top: 40 })
            .alignItems(HorizontalAlign.Center)

            // 无数据
          } else if (this.recipes.length === 0) {
            Column() {
              Text("😕")
                .fontSize(48)
              Text("暂无推荐数据")
                .fontSize(16)
                .fontColor("#999999")
                .margin({ top: 10 })
            }
            .width("100%")
            .padding({ top: 40 })
            .alignItems(HorizontalAlign.Center)

            // 有数据
          } else {
            Column() {
              ForEach(this.recipes, (item: Recipe) => {
                this.buildRecipeCard(item)
              })
            }
            .width("100%")
          }

          // 「开始使用」按钮（与全局按钮风格一致）
          Button("开始使用 🚀")
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF6B6B')
            .fontColor('#FFFFFF')
            .borderRadius(25)
            .margin({ top: 30, bottom: 40 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/HomePage' })
            })

        }
        .width("100%")
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F8F9FA")
  }
}
