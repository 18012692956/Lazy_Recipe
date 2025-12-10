import { Recipe } from '../model/Recipe'
import { ApiService } from '../common/ApiService'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'

@Entry
@Component
export struct FavoritesPage {
  @State recipes: Recipe[] = []
  @State isLoading: boolean = false

  aboutToAppear() {
    this.loadFavorites()
  }

  private async loadFavorites() {
    this.isLoading = true
    try {
      const data = await ApiService.getFavorites()
      this.recipes = data
    } catch (e) {
      console.error('加载收藏失败', e)
    } finally {
      this.isLoading = false
    }
  }

  private async toggleFavorite(recipeId: number) {
    const currentRecipe = this.recipes.find(r => r.id === recipeId);
    if (!currentRecipe) return;

    try {
      // 乐观更新：直接从列表中移除
      this.recipes = this.recipes.filter(r => r.id !== recipeId);

      // 调用后端 API
      await ApiService.updateFavorite(recipeId);

    } catch (error) {
      console.error('更新收藏失败:', error);

      // 失败时恢复：重新添加到列表
      this.recipes = [...this.recipes, currentRecipe];
    }
  }

  // ✅ 清空收藏夹
  private async clearAllFavorites() {
    if (this.recipes.length === 0) {
      promptAction.showToast({
        message: '收藏夹已经是空的了',
        duration: 2000
      });
      return;
    }

    // 显示确认对话框
    AlertDialog.show({
      title: '清空收藏夹',
      message: `确定要清空所有 ${this.recipes.length} 个收藏吗？此操作不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {
          console.log('取消清空');
        }
      },
      secondaryButton: {
        value: '确定清空',
        fontColor: '#FF6B6B',
        action: async () => {
          await this.performClearAll();
        }
      }
    });
  }

  // 执行清空操作
  private async performClearAll() {
    const backupRecipes = [...this.recipes];

    try {
      // 乐观更新：立即清空列表
      this.recipes = [];

      // 调用后端 API 批量取消收藏
      const promises = backupRecipes.map(r => ApiService.updateFavorite(r.id));
      await Promise.all(promises);

      promptAction.showToast({
        message: '已清空收藏夹',
        duration: 2000
      });

    } catch (error) {
      console.error('清空收藏失败:', error);

      // 失败时恢复
      this.recipes = backupRecipes;

      promptAction.showToast({
        message: '清空失败，请重试',
        duration: 2000
      });
    }
  }

  private navigateToDetail(recipe: Recipe) {
    router.pushUrl({
      url: 'pages/DetailPage',
      params: recipe
    })
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
          }.margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .onClick(() => this.navigateToDetail(r))

        Column() {
          Text("❤️")
            .fontSize(24)
          Text("已收藏")
            .fontSize(13)
            .margin({ top: 4 })
            .fontColor('#FF6B6B')
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

        Text('我的收藏')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        // ✅ 清空按钮
        Row() {
          Text('🗑️')
            .fontSize(20)
          Text('清空')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(this.recipes.length > 0 ? '#FFF0F0' : '#F5F5F5')
        .borderRadius(16)
        .onClick(() => {
          this.clearAllFavorites();
        })
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
          Text("正在加载收藏菜谱...")
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.recipes.length === 0) {
        Column() {
          Text("❤")
            .fontSize(64)
          Text("暂无收藏菜谱")
            .fontSize(18)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text("快去添加你喜欢的菜吧～")
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
            Text(`共收藏了 `)
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
          .padding({ left: 20, right: 20, top: 16, bottom: 8 })

          // 菜谱列表
          Scroll() {
            Column() {
              ForEach(this.recipes, (r: Recipe, i: number) => {
                Column() {
                  this.buildRecipeCard(r)
                }
              }, (r: Recipe, i: number) => `${i}-${r.id}`)
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