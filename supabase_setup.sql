-- =============================================
-- Instagram Clone - Supabase 인증 시스템 SQL
-- =============================================
-- Supabase SQL Editor에서 실행하세요.

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
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- username에 대한 인덱스 (빠른 검색)
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

-- ──────────────────────────────────────────
-- 4. RLS (Row Level Security) 정책
-- ──────────────────────────────────────────

-- RLS 활성화
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제 (재실행 시 충돌 방지)
DROP POLICY IF EXISTS "프로필 조회: 모든 인증 사용자 허용" ON public.profiles;
DROP POLICY IF EXISTS "프로필 수정: 본인만 허용" ON public.profiles;

-- 정책 1: 프로필 조회 - 모든 인증된 사용자 허용
CREATE POLICY "프로필 조회: 모든 인증 사용자 허용"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- 정책 2: 프로필 수정 - 본인만 허용
CREATE POLICY "프로필 수정: 본인만 허용"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
