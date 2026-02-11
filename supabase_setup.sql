-- =============================================
-- Instagram Clone - Supabase 전체 데이터베이스 스키마
-- =============================================
-- Supabase SQL Editor에서 순서대로 실행하세요.

-- ══════════════════════════════════════════════
-- PART 1: 기본 설정 & profiles 테이블
-- ══════════════════════════════════════════════

-- ──────────────────────────────────────────
-- 1. profiles 테이블 생성
-- ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  bio TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  website TEXT,
  followers_count INT DEFAULT 0 NOT NULL,
  following_count INT DEFAULT 0 NOT NULL,
  posts_count INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- username 인덱스 (빠른 검색)
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles (username);

-- ──────────────────────────────────────────
-- 2. updated_at 자동 갱신 트리거 함수
-- ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- profiles 테이블에 updated_at 트리거 적용
DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ──────────────────────────────────────────
-- 3. 신규 회원가입 시 profiles 자동 생성 트리거
-- ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || LEFT(NEW.id::text, 8)),
    COALESCE(NEW.raw_user_meta_data->>'display_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- auth.users에 INSERT 트리거 적용
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- profiles RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "프로필 조회: 모든 인증 사용자 허용" ON public.profiles;
DROP POLICY IF EXISTS "프로필 수정: 본인만 허용" ON public.profiles;

CREATE POLICY "프로필 조회: 모든 인증 사용자 허용"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "프로필 수정: 본인만 허용"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);


-- ══════════════════════════════════════════════
-- PART 2: posts 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  caption TEXT,
  location TEXT DEFAULT '',
  likes_count INT DEFAULT 0 NOT NULL,
  comments_count INT DEFAULT 0 NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- posts 인덱스
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON public.posts (user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts (created_at DESC);

-- posts updated_at 트리거
DROP TRIGGER IF EXISTS on_posts_updated ON public.posts;
CREATE TRIGGER on_posts_updated
  BEFORE UPDATE ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- posts RLS
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "게시물 조회: 인증 사용자 허용" ON public.posts;
DROP POLICY IF EXISTS "게시물 생성: 인증 사용자 허용" ON public.posts;
DROP POLICY IF EXISTS "게시물 수정: 본인만 허용" ON public.posts;
DROP POLICY IF EXISTS "게시물 삭제: 본인만 허용" ON public.posts;

CREATE POLICY "게시물 조회: 인증 사용자 허용"
  ON public.posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "게시물 생성: 인증 사용자 허용"
  ON public.posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "게시물 수정: 본인만 허용"
  ON public.posts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "게시물 삭제: 본인만 허용"
  ON public.posts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 3: comments 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- comments 인덱스
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments (post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments (user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON public.comments (post_id, created_at DESC);

-- comments RLS
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "댓글 조회: 인증 사용자 허용" ON public.comments;
DROP POLICY IF EXISTS "댓글 생성: 인증 사용자 허용" ON public.comments;
DROP POLICY IF EXISTS "댓글 삭제: 본인만 허용" ON public.comments;

CREATE POLICY "댓글 조회: 인증 사용자 허용"
  ON public.comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "댓글 생성: 인증 사용자 허용"
  ON public.comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "댓글 삭제: 본인만 허용"
  ON public.comments FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 4: likes 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (post_id, user_id)
);

-- likes 인덱스
CREATE INDEX IF NOT EXISTS idx_likes_post_id ON public.likes (post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON public.likes (user_id);

-- likes RLS
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "좋아요 조회: 인증 사용자 허용" ON public.likes;
DROP POLICY IF EXISTS "좋아요 생성: 인증 사용자 허용" ON public.likes;
DROP POLICY IF EXISTS "좋아요 삭제: 본인만 허용" ON public.likes;

CREATE POLICY "좋아요 조회: 인증 사용자 허용"
  ON public.likes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "좋아요 생성: 인증 사용자 허용"
  ON public.likes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "좋아요 삭제: 본인만 허용"
  ON public.likes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 5: follows 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (follower_id, following_id),
  CHECK (follower_id != following_id)
);

-- follows 인덱스
CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON public.follows (follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON public.follows (following_id);

-- follows RLS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "팔로우 조회: 인증 사용자 허용" ON public.follows;
DROP POLICY IF EXISTS "팔로우 생성: 인증 사용자 허용" ON public.follows;
DROP POLICY IF EXISTS "팔로우 삭제: 본인만 허용" ON public.follows;

CREATE POLICY "팔로우 조회: 인증 사용자 허용"
  ON public.follows FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "팔로우 생성: 인증 사용자 허용"
  ON public.follows FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "팔로우 삭제: 본인만 허용"
  ON public.follows FOR DELETE
  TO authenticated
  USING (auth.uid() = follower_id);


-- ══════════════════════════════════════════════
-- PART 6: stories 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  expires_at TIMESTAMPTZ DEFAULT (now() + INTERVAL '24 hours') NOT NULL
);

-- stories 인덱스
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON public.stories (user_id);
CREATE INDEX IF NOT EXISTS idx_stories_expires_at ON public.stories (expires_at);
CREATE INDEX IF NOT EXISTS idx_stories_active ON public.stories (user_id, expires_at DESC);

-- stories RLS
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "스토리 조회: 인증 사용자 허용" ON public.stories;
DROP POLICY IF EXISTS "스토리 생성: 인증 사용자 허용" ON public.stories;
DROP POLICY IF EXISTS "스토리 삭제: 본인만 허용" ON public.stories;

CREATE POLICY "스토리 조회: 인증 사용자 허용"
  ON public.stories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "스토리 생성: 인증 사용자 허용"
  ON public.stories FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "스토리 삭제: 본인만 허용"
  ON public.stories FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 7: saved_posts 테이블
-- ══════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.saved_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  UNIQUE (user_id, post_id)
);

-- saved_posts 인덱스
CREATE INDEX IF NOT EXISTS idx_saved_posts_user_id ON public.saved_posts (user_id);
CREATE INDEX IF NOT EXISTS idx_saved_posts_post_id ON public.saved_posts (post_id);

-- saved_posts RLS
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "저장 조회: 본인만 허용" ON public.saved_posts;
DROP POLICY IF EXISTS "저장 생성: 인증 사용자 허용" ON public.saved_posts;
DROP POLICY IF EXISTS "저장 삭제: 본인만 허용" ON public.saved_posts;

CREATE POLICY "저장 조회: 본인만 허용"
  ON public.saved_posts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "저장 생성: 인증 사용자 허용"
  ON public.saved_posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "저장 삭제: 본인만 허용"
  ON public.saved_posts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 8: notifications 테이블
-- ══════════════════════════════════════════════

-- 알림 타입 ENUM 생성
DO $$ BEGIN
  CREATE TYPE public.notification_type AS ENUM ('like', 'comment', 'follow');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  actor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  type public.notification_type NOT NULL,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT false NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- notifications 인덱스
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications (user_id)
  WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_actor_id ON public.notifications (actor_id);

-- notifications RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "알림 조회: 본인만 허용" ON public.notifications;
DROP POLICY IF EXISTS "알림 생성: 인증 사용자 허용" ON public.notifications;
DROP POLICY IF EXISTS "알림 수정: 본인만 허용 (읽음 처리)" ON public.notifications;
DROP POLICY IF EXISTS "알림 삭제: 본인만 허용" ON public.notifications;

CREATE POLICY "알림 조회: 본인만 허용"
  ON public.notifications FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "알림 생성: 인증 사용자 허용"
  ON public.notifications FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = actor_id);

CREATE POLICY "알림 수정: 본인만 허용 (읽음 처리)"
  ON public.notifications FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "알림 삭제: 본인만 허용"
  ON public.notifications FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);


-- ══════════════════════════════════════════════
-- PART 9: 카운터 자동 갱신 트리거 함수들
-- ══════════════════════════════════════════════

-- ── likes_count 자동 갱신 ──
CREATE OR REPLACE FUNCTION public.handle_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_like_changed ON public.likes;
CREATE TRIGGER on_like_changed
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_likes_count();

-- ── comments_count 자동 갱신 ──
CREATE OR REPLACE FUNCTION public.handle_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.posts SET comments_count = GREATEST(comments_count - 1, 0) WHERE id = OLD.post_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_comment_changed ON public.comments;
CREATE TRIGGER on_comment_changed
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_comments_count();

-- ── followers_count / following_count 자동 갱신 ──
CREATE OR REPLACE FUNCTION public.handle_follow_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
    UPDATE public.profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = OLD.following_id;
    UPDATE public.profiles SET following_count = GREATEST(following_count - 1, 0) WHERE id = OLD.follower_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_changed ON public.follows;
CREATE TRIGGER on_follow_changed
  AFTER INSERT OR DELETE ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_follow_count();

-- ── posts_count 자동 갱신 ──
CREATE OR REPLACE FUNCTION public.handle_posts_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles SET posts_count = posts_count + 1 WHERE id = NEW.user_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles SET posts_count = GREATEST(posts_count - 1, 0) WHERE id = OLD.user_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_post_changed ON public.posts;
CREATE TRIGGER on_post_changed
  AFTER INSERT OR DELETE ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_posts_count();


-- ══════════════════════════════════════════════
-- PART 10: 자동 알림 생성 트리거 함수들
-- ══════════════════════════════════════════════

-- ── 좋아요 알림 ──
CREATE OR REPLACE FUNCTION public.handle_like_notification()
RETURNS TRIGGER AS $$
DECLARE
  post_owner_id UUID;
BEGIN
  SELECT user_id INTO post_owner_id FROM public.posts WHERE id = NEW.post_id;
  -- 자기 게시물에 좋아요 시 알림 제외
  IF post_owner_id IS NOT NULL AND post_owner_id != NEW.user_id THEN
    INSERT INTO public.notifications (user_id, actor_id, type, post_id)
    VALUES (post_owner_id, NEW.user_id, 'like', NEW.post_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_like_notify ON public.likes;
CREATE TRIGGER on_like_notify
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_like_notification();

-- ── 댓글 알림 ──
CREATE OR REPLACE FUNCTION public.handle_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
  post_owner_id UUID;
BEGIN
  SELECT user_id INTO post_owner_id FROM public.posts WHERE id = NEW.post_id;
  -- 자기 게시물에 댓글 시 알림 제외
  IF post_owner_id IS NOT NULL AND post_owner_id != NEW.user_id THEN
    INSERT INTO public.notifications (user_id, actor_id, type, post_id)
    VALUES (post_owner_id, NEW.user_id, 'comment', NEW.post_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_comment_notify ON public.comments;
CREATE TRIGGER on_comment_notify
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_comment_notification();

-- ── 팔로우 알림 ──
CREATE OR REPLACE FUNCTION public.handle_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (user_id, actor_id, type)
  VALUES (NEW.following_id, NEW.follower_id, 'follow');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_notify ON public.follows;
CREATE TRIGGER on_follow_notify
  AFTER INSERT ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_follow_notification();


-- ══════════════════════════════════════════════
-- PART 11: Supabase Storage 버킷 설정
-- ══════════════════════════════════════════════
-- 아래는 Supabase Dashboard > Storage 에서 설정하거나,
-- supabase CLI 또는 SQL로 실행합니다.

-- avatars 버킷 (프로필 사진)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- posts 버킷 (게시물 이미지)
INSERT INTO storage.buckets (id, name, public)
VALUES ('posts', 'posts', true)
ON CONFLICT (id) DO NOTHING;

-- stories 버킷 (스토리 이미지)
INSERT INTO storage.buckets (id, name, public)
VALUES ('stories', 'stories', true)
ON CONFLICT (id) DO NOTHING;

-- ── Storage RLS 정책 ──

-- avatars: 공개 읽기
DROP POLICY IF EXISTS "아바타 공개 읽기" ON storage.objects;
CREATE POLICY "아바타 공개 읽기"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- avatars: 본인만 업로드
DROP POLICY IF EXISTS "아바타 업로드: 본인만 허용" ON storage.objects;
CREATE POLICY "아바타 업로드: 본인만 허용"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- avatars: 본인만 수정
DROP POLICY IF EXISTS "아바타 수정: 본인만 허용" ON storage.objects;
CREATE POLICY "아바타 수정: 본인만 허용"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- avatars: 본인만 삭제
DROP POLICY IF EXISTS "아바타 삭제: 본인만 허용" ON storage.objects;
CREATE POLICY "아바타 삭제: 본인만 허용"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- posts: 공개 읽기
DROP POLICY IF EXISTS "게시물 이미지 공개 읽기" ON storage.objects;
CREATE POLICY "게시물 이미지 공개 읽기"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'posts');

-- posts: 인증 사용자 업로드
DROP POLICY IF EXISTS "게시물 이미지 업로드: 인증 사용자 허용" ON storage.objects;
CREATE POLICY "게시물 이미지 업로드: 인증 사용자 허용"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'posts'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- posts: 본인만 삭제
DROP POLICY IF EXISTS "게시물 이미지 삭제: 본인만 허용" ON storage.objects;
CREATE POLICY "게시물 이미지 삭제: 본인만 허용"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'posts'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- stories: 공개 읽기
DROP POLICY IF EXISTS "스토리 이미지 공개 읽기" ON storage.objects;
CREATE POLICY "스토리 이미지 공개 읽기"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'stories');

-- stories: 인증 사용자 업로드
DROP POLICY IF EXISTS "스토리 이미지 업로드: 인증 사용자 허용" ON storage.objects;
CREATE POLICY "스토리 이미지 업로드: 인증 사용자 허용"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'stories'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- stories: 본인만 삭제
DROP POLICY IF EXISTS "스토리 이미지 삭제: 본인만 허용" ON storage.objects;
CREATE POLICY "스토리 이미지 삭제: 본인만 허용"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'stories'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );


-- ══════════════════════════════════════════════
-- 완료! 모든 테이블, 인덱스, RLS, 트리거, 스토리지 설정 완료
-- ══════════════════════════════════════════════
