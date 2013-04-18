(* /*****************************************************************
  //                       Delphi-OpenCV Demo
  //               Copyright (C) 2013 Project Delphi-OpenCV
  // ****************************************************************
  // Contributor:
  // laentir Valetov
  // email:laex@bk.ru
  // ****************************************************************
  // You may retrieve the latest version of this file at the GitHub,
  // located at git://github.com/Laex/Delphi-OpenCV.git
  // ****************************************************************
  // The contents of this file are used with permission, subject to
  // the Mozilla Public License Version 1.1 (the "License"); you may
  // not use this file except in compliance with the License. You may
  // obtain a copy of the License at
  // http://www.mozilla.org/MPL/MPL-1_1Final.html
  //
  // Software distributed under the License is distributed on an
  // "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  // implied. See the License for the specific language governing
  // rights and limitations under the License.
  ******************************************************************* *)
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program cvSplit_cvMerge;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  uLibName in '..\..\..\include\uLibName.pas',
  highgui_c in '..\..\..\include\highgui\highgui_c.pas',
  core_c in '..\..\..\include\core\core_c.pas',
  Core.types_c in '..\..\..\include\core\Core.types_c.pas',
  imgproc.types_c in '..\..\..\include\imgproc\imgproc.types_c.pas',
  imgproc_c in '..\..\..\include\imgproc\imgproc_c.pas',
  legacy in '..\..\..\include\legacy\legacy.pas',
  calib3d in '..\..\..\include\calib3d\calib3d.pas',
  imgproc in '..\..\..\include\imgproc\imgproc.pas',
  haar in '..\..\..\include\objdetect\haar.pas',
  objdetect in '..\..\..\include\objdetect\objdetect.pas',
  tracking in '..\..\..\include\video\tracking.pas',
  Core in '..\..\..\include\core\core.pas';

const
  filename = 'Resource\cat2.jpg';

Var
  image: pIplImage = nil;
  gray: pIplImage = nil;
  dst: pIplImage = nil;
  dst2: pIplImage = nil;
  // ��� �������� ��������� c��� RGB-�����������
  r: pIplImage = nil;
  g: pIplImage = nil;
  b: pIplImage = nil;
  temp: pIplImage = nil;

  t1, t2, t3: pIplImage; // ��� �������������� ��������

begin
  try
    // �������� ��������
    image := cvLoadImage(filename, 1);
    WriteLn(Format('[i] image: %s', [filename]));

    // ������� �����������
    cvNamedWindow('original', CV_WINDOW_AUTOSIZE);
    cvShowImage('original', image);

    // �������� ��� �������� ����������� � ��������� c�����
    gray := cvCreateImage(cvGetSize(image), image^.depth, 1);

    // ����������� �������� � �������� c�����
    cvConvertImage(image, gray, CV_BGR2GRAY);

    // ������� c���� ��������
    cvNamedWindow('gray', 1);
    cvShowImage('gray', gray);

    dst := cvCreateImage(cvGetSize(gray), IPL_DEPTH_8U, 1);
    dst2 := cvCreateImage(cvGetSize(gray), IPL_DEPTH_8U, 1);

    // ��������� �������������� ��� ��������� � ��������� c�����
    cvThreshold(gray, dst, 50, 250, CV_THRESH_BINARY);
    cvAdaptiveThreshold(gray, dst2, 250, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 7, 1);

    // ���������� ����������
    cvNamedWindow('cvThreshold', 1);
    cvShowImage('cvThreshold', dst);
    cvNamedWindow('cvAdaptiveThreshold', 1);
    cvShowImage('cvAdaptiveThreshold', dst2);

    // :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
    //
    // ������� ��������� �������������� ��� RGB-���������
    //

    r := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    g := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    b := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);

    // ��������� �� ��������� c���
    cvSplit(image, b, g, r, 0);

    // �������� ��� �������� ������������� �����������
    temp := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);

    // c��������� �������� c ���������� ��c��
    cvAddWeighted(r, 1.0 / 3.0, g, 1.0 / 3.0, 0.0, temp);
    cvAddWeighted(temp, 2.0 / 3.0, b, 1.0 / 3.0, 0.0, temp);

    // ��������� ��������� ��������������
    cvThreshold(temp, dst, 50, 250, CV_THRESH_BINARY);

    cvReleaseImage(&temp);

    // ���������� ���������
    cvNamedWindow('RGB cvThreshold', 1);
    cvShowImage('RGB cvThreshold', dst);

    //
    // ��������� ��������� �������������� ��� ���������� c�����
    //

    t1 := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    t2 := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
    t3 := cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);

    // ��������� ��������� ��������������
    cvThreshold(r, t1, 50, 250, CV_THRESH_BINARY);
    cvThreshold(g, t2, 50, 250, CV_THRESH_BINARY);
    cvThreshold(b, t3, 50, 250, CV_THRESH_BINARY);

    // c��������� ����������
    cvMerge(t3, t2, t1, 0, image);

    cvNamedWindow('RGB cvThreshold 2', 1);
    cvShowImage('RGB cvThreshold 2', image);

    cvReleaseImage(&t1);
    cvReleaseImage(&t2);
    cvReleaseImage(&t3);

    // :=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

    // ��� ������� �������
    cvWaitKey(0);

    // �c��������� ��c��c�
    cvReleaseImage(image);
    cvReleaseImage(gray);
    cvReleaseImage(dst);
    cvReleaseImage(dst2);
    cvReleaseImage(r);
    cvReleaseImage(g);
    cvReleaseImage(b);
    // ������� ����
    cvDestroyAllWindows();
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
