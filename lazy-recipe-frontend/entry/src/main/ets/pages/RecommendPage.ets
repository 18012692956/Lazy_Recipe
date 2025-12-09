import { ApiService } from '../common/ApiService';
import { Recipe } from '../model/Recipe';
import { RecommendRequest } from '../model/Request';
import router from '@ohos.router';

@Entry
@Component
export struct RecommendPage {

  @State recipes: Recipe[] = [];
  @State isLoading: boolean = false;

  private navParams: RecommendRequest = {
    ingredients: [],
    taste: "",
    style: ""
  };

  aboutToAppear() {
    const params = router.getParams();
    if (params) {
      this.navParams = params as RecommendRequest;
    }
    this.loadRecipes();
  }

  private async loadRecipes() {
    this.isLoading = true;
    try {
      const freshRecipes = await ApiService.recommend(
        this.navParams.ingredients,
        this.navParams.taste,
        this.navParams.style
      );
      this.recipes = freshRecipes;
    } catch (error) {
      console.error('加载失败:', error);
    } finally {
      this.isLoading = false;
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
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DetailPage',
            params: r
          });
        })

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
    .shadow({
      radius: 12,
      color: '#15000000',
      offsetX: 0,
      offsetY: 4
    })
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

        Text('推荐菜谱')
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

      // 主内容区
      if (this.isLoading) {
        Column() {
          Text("⏳")
            .fontSize(48)
          Text("正在为您推荐美食...")
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

      } else if (this.recipes.length === 0) {
        Column() {
          Text("🍳")
            .fontSize(64)
          Text("暂无推荐菜谱")
            .fontSize(18)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text("试试调整筛选条件")
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

      } else {
        // ✅ 菜谱列表（从顶部开始）
        Scroll() {
          Column() {
            // 结果统计
            Row() {
              Text(`为您找到 `)
                .fontSize(15)
                .fontColor('#666666')
              Text(`${this.recipes.length}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B6B')
              Text(` 道菜谱`)
                .fontSize(15)
                .fontColor('#666666')
            }
            .width('100%')
            .margin({ top: 16, bottom: 8 })

            // 菜谱卡片列表
            ForEach(this.recipes, (r: Recipe, index: number) => {
              Column() {
                this.buildRecipeCard(r)
              }
            }, (r: Recipe, index: number) => `${index}-${r.id}-${r.favorite}`)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .align(Alignment.Top) // ✅ 从顶部对齐
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}